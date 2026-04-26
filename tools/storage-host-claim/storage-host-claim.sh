#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/storage-host-claim.env}"

[[ -f "$ENV_FILE" ]] || {
  echo "[ERR ] Missing env file: $ENV_FILE" >&2
  exit 1
}

# shellcheck disable=SC1090
source "$ENV_FILE"

log()  { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die()  { printf '[ERR ] %s\n' "$*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

kctl() {
  sudo KUBECONFIG="$KUBECONFIG_PATH" kubectl "$@"
}

get_local_hostname() {
  hostname -s | tr '[:upper:]' '[:lower:]'
}

get_wg_ip() {
  ip -4 addr show wg0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1
}

device_present() {
  blkid -U "$DEVICE_UUID" >/dev/null 2>&1
}

device_path() {
  blkid -U "$DEVICE_UUID" || true
}

mountpoint_is_active() {
  mountpoint -q "$MOUNTPOINT"
}

mount_source_for_mountpoint() {
  findmnt -no SOURCE --target "$MOUNTPOINT" 2>/dev/null || true
}

mounted_uuid_matches() {
  local src
  src="$(mount_source_for_mountpoint)"
  [[ -n "$src" ]] || return 1
  local mounted_uuid
  mounted_uuid="$(blkid -o value -s UUID "$src" 2>/dev/null || true)"
  [[ "$mounted_uuid" == "$DEVICE_UUID" ]]
}

exports_line() {
  printf '%s %s(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash) %s(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)\n' \
    "$MOUNTPOINT" "$LAN_CIDR" "$WG_CIDR"
}

exports_file_ok() {
  grep -Fxq "$(exports_line)" /etc/exports 2>/dev/null
}

write_exports_file() {
  printf '%s' "$(exports_line)" | sudo tee /etc/exports >/dev/null
}

reload_exports() {
  sudo exportfs -ra
}

show_exports() {
  sudo exportfs -v
  showmount -e localhost || true
}

node_allowed() {
  local node="$1"
  [[ " ${CLAIMANT_NODES[*]} " == *" ${node} "* ]]
}

node_exists() {
  local node="$1"
  kctl get node "$node" >/dev/null 2>&1
}

remove_label_from_other_nodes() {
  local target_node="$1"
  local n
  for n in "${CLAIMANT_NODES[@]}"; do
    node_exists "$n" || continue
    if [[ "$n" != "$target_node" ]]; then
      log "Removing ${HOST_LABEL_KEY} from node: $n"
      kctl label node "$n" "${HOST_LABEL_KEY}-" >/dev/null 2>&1 || true
    fi
  done
}

set_label_on_target_node() {
  local target_node="$1"
  log "Setting ${HOST_LABEL_KEY}=${HOST_LABEL_VALUE} on node: $target_node"
  kctl label node "$target_node" "${HOST_LABEL_KEY}=${HOST_LABEL_VALUE}" --overwrite >/dev/null
}

patch_wg_provisioner() {
  local wg_ip="$1"
  log "Patching WG provisioner to NFS server ${wg_ip}"
  kctl -n "$WG_PROVISIONER_NAMESPACE" patch deploy "$WG_PROVISIONER_DEPLOY" --type='json' -p="[
    {\"op\":\"replace\",\"path\":\"/spec/template/spec/containers/0/env/1/value\",\"value\":\"${wg_ip}\"},
    {\"op\":\"replace\",\"path\":\"/spec/template/spec/volumes/0/nfs/server\",\"value\":\"${wg_ip}\"}
  ]" >/dev/null
}

rollout_wg_provisioner() {
  log "Waiting for WG provisioner rollout"
  kctl -n "$WG_PROVISIONER_NAMESPACE" rollout status "deploy/${WG_PROVISIONER_DEPLOY}"
}

show_cluster_state() {
  log "Current storage-host labels:"
  kctl get nodes --show-labels | egrep 'benq|minisone|ministwo|pvcstore-host' || true
  log "WG provisioner live NFS target:"
  kctl -n "$WG_PROVISIONER_NAMESPACE" get deploy "$WG_PROVISIONER_DEPLOY" -o yaml | grep -A2 -E 'NFS_SERVER|server:' || true
}

run_local_checks() {
  need_cmd hostname
  need_cmd ip
  need_cmd blkid
  need_cmd mountpoint
  need_cmd findmnt
  need_cmd grep
  need_cmd awk
  need_cmd sudo
  need_cmd exportfs
  need_cmd showmount

  local local_node wg_ip
  local_node="$(get_local_hostname)"
  wg_ip="$(get_wg_ip)"

  node_allowed "$local_node" || die "Local node '${local_node}' is not in claimant set: ${CLAIMANT_NODES[*]}"
  [[ -n "$wg_ip" ]] || die "wg0 IP not found on local node"

  device_present || die "Expected storage device UUID not present: ${DEVICE_UUID}"
  mountpoint_is_active || die "Mountpoint not active: ${MOUNTPOINT}"
  mounted_uuid_matches || die "Mounted filesystem at ${MOUNTPOINT} does not match expected UUID ${DEVICE_UUID}"

  if ! exports_file_ok; then
    warn "/etc/exports does not match expected line."
    warn "Expected:"
    exports_line
    if [[ "$AUTO_WRITE_EXPORTS" == "1" ]]; then
      log "Writing /etc/exports"
      write_exports_file
      reload_exports
    else
      die "Refusing to continue without valid /etc/exports. Re-run with AUTO_WRITE_EXPORTS=1 or fix manually."
    fi
  fi

  log "Check summary:"
  log "  local node      : ${local_node}"
  log "  wg0 IP          : ${wg_ip}"
  log "  device path     : $(device_path)"
  log "  mountpoint      : ${MOUNTPOINT}"
  log "  mounted source  : $(mount_source_for_mountpoint)"
}

emit_facts() {
  local local_node wg_ip
  local_node="$(get_local_hostname)"
  wg_ip="$(get_wg_ip)"

  printf 'NODE=%s\n' "$local_node"
  printf 'WG_IP=%s\n' "$wg_ip"
  printf 'DEVICE_UUID=%s\n' "$DEVICE_UUID"
  printf 'DEVICE_PATH=%s\n' "$(device_path)"
  printf 'MOUNTPOINT=%s\n' "$MOUNTPOINT"
  printf 'MOUNT_SOURCE=%s\n' "$(mount_source_for_mountpoint)"
}

wait_for_pv_cleanup() {
  local deadline now left
  deadline=$((SECONDS + PVC_WAIT_SECONDS))
  while true; do
    if ! kctl get pv 2>/dev/null | egrep -q 'wg-canary|wg-canary-pod-config'; then
      log "No stale canary PVs detected."
      return 0
    fi
    now=$SECONDS
    left=$((deadline - now))
    [[ $left -gt 0 ]] || die "Timed out waiting for stale canary PV cleanup."
    sleep 2
  done
}

wait_for_pvcs_bound() {
  local deadline status output
  deadline=$((SECONDS + PVC_WAIT_SECONDS))
  while true; do
    output="$(kctl -n "$CANARY_NAMESPACE" get pvc "${CANARY_PVC_NAMES[@]}" --no-headers 2>/dev/null || true)"
    if [[ -n "$output" ]] && echo "$output" | awk '{print $2}' | grep -vq '^Bound$'; then
      :
    elif [[ -n "$output" ]]; then
      log "Canary PVCs are Bound."
      return 0
    fi
    [[ $SECONDS -lt $deadline ]] || die "Timed out waiting for canary PVCs to bind."
    sleep 2
  done
}

wait_for_canary_running() {
  local deadline phase
  deadline=$((SECONDS + CANARY_WAIT_SECONDS))
  while true; do
    phase="$(kctl -n "$CANARY_NAMESPACE" get pod "$CANARY_POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
    if [[ "$phase" == "Running" ]]; then
      log "Canary pod is Running."
      return 0
    fi
    [[ $SECONDS -lt $deadline ]] || die "Timed out waiting for canary pod to reach Running."
    sleep 2
  done
}

refresh_canary() {
  need_cmd kubectl

  log "Deleting canary pod if present"
  kctl -n "$CANARY_NAMESPACE" delete pod "$CANARY_POD_NAME" --ignore-not-found >/dev/null 2>&1 || true

  log "Deleting canary PVCs"
  kctl -n "$CANARY_NAMESPACE" delete pvc "${CANARY_PVC_NAMES[@]}" --ignore-not-found >/dev/null 2>&1 || true

  wait_for_pv_cleanup

  log "Recreating canary PVC manifests"
  local pvc_manifest
  for pvc_manifest in "${CANARY_PVC_MANIFESTS[@]}"; do
    [[ -f "$SCRIPT_DIR/$pvc_manifest" ]] || die "Missing canary PVC manifest: $SCRIPT_DIR/$pvc_manifest"
    kctl apply -f "$SCRIPT_DIR/$pvc_manifest" >/dev/null
  done

  wait_for_pvcs_bound

  [[ -f "$SCRIPT_DIR/$CANARY_POD_MANIFEST" ]] || die "Missing canary pod manifest: $SCRIPT_DIR/$CANARY_POD_MANIFEST"
  log "Recreating canary pod"
  kctl apply -f "$SCRIPT_DIR/$CANARY_POD_MANIFEST" >/dev/null

  wait_for_canary_running

  log "Canary refresh complete."
  kctl -n "$CANARY_NAMESPACE" get pod "$CANARY_POD_NAME" -o wide
}

run_claim_remote() {
  [[ $# -eq 2 ]] || die "--claim-remote requires: <target-node> <target-wg-ip>"
  need_cmd kubectl

  local target_node="$1"
  local target_wg_ip="$2"

  node_allowed "$target_node" || die "Target node '${target_node}' is not in claimant set: ${CLAIMANT_NODES[*]}"
  node_exists "$target_node" || die "Target node '${target_node}' does not exist in cluster"
  [[ -n "$target_wg_ip" ]] || die "Target WG IP is empty"

  remove_label_from_other_nodes "$target_node"
  set_label_on_target_node "$target_node"

  patch_wg_provisioner "$target_wg_ip"
  rollout_wg_provisioner

  log "Remote claim complete."
  show_cluster_state

  cat <<EOF
SUMMARY
-------
Storage host claimed by : ${target_node}
WG IP used             : ${target_wg_ip}
EOF
}

run_claim_and_refresh() {
  [[ $# -eq 2 ]] || die "--claim-and-refresh requires: <target-node> <target-wg-ip>"
  run_claim_remote "$1" "$2"
  refresh_canary
}

usage() {
  cat <<'EOF'
Usage:
  storage-host-claim.sh --check
  storage-host-claim.sh --facts
  storage-host-claim.sh --claim-remote <target-node> <target-wg-ip>
  storage-host-claim.sh --refresh-canary
  storage-host-claim.sh --claim-and-refresh <target-node> <target-wg-ip>

Modes:
  --check
      Local-only validation on the node that physically has the disk.

  --facts
      Local-only validation + shell-friendly facts output.

  --claim-remote <node> <wg-ip>
      Cluster mutation from a kubectl-capable node.

  --refresh-canary
      Rebuild validation-lane PVCs/PVs and recreate the canary pod.

  --claim-and-refresh <node> <wg-ip>
      Do the remote claim, then refresh the validation lane.
EOF
}

main() {
  [[ $# -ge 1 ]] || { usage; exit 1; }

  case "$1" in
    --check)
      [[ $# -eq 1 ]] || die "--check takes no extra args"
      run_local_checks
      ;;
    --facts)
      [[ $# -eq 1 ]] || die "--facts takes no extra args"
      run_local_checks
      emit_facts
      ;;
    --claim-remote)
      shift
      run_claim_remote "$@"
      ;;
    --refresh-canary)
      [[ $# -eq 1 ]] || die "--refresh-canary takes no extra args"
      refresh_canary
      ;;
    --claim-and-refresh)
      shift
      run_claim_and_refresh "$@"
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
