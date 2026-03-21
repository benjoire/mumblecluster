#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() { echo "ERROR: $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# 🔴 NEW DEFAULT → GitHub cluster_snapshots
LKG_BASE="${LKG_BASE:-/data/github/mumblecluster/cluster_snapshots}"
LKG_DATE="${LKG_DATE:-$(date +%F_%H%M%S)}"
LKG_IDENTITY="${LKG_IDENTITY:-LKG}"

PAYLOAD_DIR="${PAYLOAD_DIR:-${LKG_BASE}/LKG-${LKG_DATE}}"
SEAL_DIR="${SEAL_DIR:-${LKG_BASE}/_seals}"

DRYRUN="${DRYRUN:-0}"

SIGN_USER="${SIGN_USER:-$(id -un)}"
SIGN_GROUP="${SIGN_GROUP:-$(id -gn)}"

have gpg || die "gpg not found"
have sha256sum || die "sha256sum not found"
have rsync || die "rsync not found"
have kubectl || die "kubectl not found"

mkdir -p "$PAYLOAD_DIR" "$SEAL_DIR"

# --- SUDO GUARD ---
if ! sudo -n true 2>/dev/null; then
  die "sudo is not primed. Run: sudo -v"
fi

echo "==> Payload: $PAYLOAD_DIR"

# =========================================================
# 🧬 1. RUNTIME CLUSTER DUMP (FROM YOUR _dumps.txt)
# =========================================================

echo "==> Runtime cluster dump..."

cd "$PAYLOAD_DIR"

# --- core kubectl dumps ---
kubectl get nodes -o wide > nodes.txt
kubectl get pods -A -o wide > pods.txt
kubectl get svc -A > services.txt
kubectl get ingress -A > ingress.txt
kubectl get endpoints -A > endpoints.txt
kubectl get configmaps -A > configmaps.txt
kubectl get secrets -A > secrets.txt

mkdir -p yaml
kubectl get nodes -o yaml > yaml/nodes.yaml
kubectl get pods -A -o yaml > yaml/pods.yaml
kubectl get svc -A -o yaml > yaml/services.yaml
kubectl get ingress -A -o yaml > yaml/ingress.yaml
kubectl get endpoints -A -o yaml > yaml/endpoints.yaml

# --- system ---
mkdir -p system
sudo cp -r /etc/rancher/rke2 system/rke2_config 2>/dev/null || true
sudo cp -r /var/lib/rancher/rke2/agent/etc/cni system/cni 2>/dev/null || true
sudo ip a > system/ip_a.txt
sudo ip r > system/ip_route.txt
sudo ss -tulpen > system/ports.txt
uname -a > system/uname.txt

# --- cilium ---
mkdir -p cilium
kubectl -n kube-system get pods -l k8s-app=cilium -o wide > cilium/pods.txt
cilium status > cilium/status.txt 2>/dev/null || true
cilium endpoint list > cilium/endpoints.txt 2>/dev/null || true
cilium service list > cilium/services.txt 2>/dev/null || true
cilium bpf lb list > cilium/bpf_lb.txt 2>/dev/null || true

# --- ingress ---
mkdir -p ingress
kubectl -n ingress-nginx get all > ingress/all.txt
kubectl -n ingress-nginx get svc -o yaml > ingress/svc.yaml
kubectl -n ingress-nginx get deploy -o yaml > ingress/deploy.yaml
kubectl -n ingress-nginx logs -l app.kubernetes.io/name=ingress-nginx > ingress/logs.txt

# --- workload ---
mkdir -p workload
kubectl get pods -A | grep webtop > workload/webtop_pods.txt || true
kubectl describe pod -A | grep -A20 webtop > workload/webtop_describe.txt || true
kubectl logs -A | grep -i webtop > workload/webtop_logs.txt || true

# --- network ---
mkdir -p network
ip a > network/ip_a.txt
ip r > network/ip_r.txt
iptables-save > network/iptables.txt 2>/dev/null || true
nft list ruleset > network/nft.txt 2>/dev/null || true

# --- tunnel ---
mkdir -p tunnel
wg show > tunnel/wg.txt 2>/dev/null || true
ip route show table all > tunnel/routes_all.txt

# =========================================================
# 🔒 2. INFRA MIRROR (YOUR ORIGINAL PART)
# =========================================================

echo "==> Mirroring system config..."

RSYNC_OPTS=(-a --delete --numeric-ids --one-file-system)

SOURCES=(
  "/etc/openvpn/::etc-openvpn::sudo"
  "/etc/wireguard/::etc-wireguard::sudo"
  "/etc/rancher/::etc-rancher::sudo"
  "/etc/rke2/::etc-rke2::sudo"
  "/var/lib/rancher/rke2/server/manifests/::rke2-manifests::sudo"
)

for item in "${SOURCES[@]}"; do
  SRC="${item%%::*}"
  SUB="${item#*::}"
  SUB="${SUB%%::*}"
  MODE="${item##*::}"

  DST="${PAYLOAD_DIR}/${SUB}/"
  mkdir -p "$DST"

  if [[ "$MODE" == "sudo" ]]; then
    sudo rsync "${RSYNC_OPTS[@]}" "$SRC" "$DST" || true
  else
    rsync "${RSYNC_OPTS[@]}" "$SRC" "$DST" || true
  fi
done

# =========================================================
# 🔐 3. MANIFEST + SIGNATURE
# =========================================================

BASE_NAME="${LKG_IDENTITY}-${LKG_DATE}"
MANIFEST="${SEAL_DIR}/${BASE_NAME}.sha256"
SIG="${MANIFEST}.asc"

echo "==> Writing manifest..."

sudo find "$PAYLOAD_DIR" -type f -print0 \
  | sudo sort -z \
  | sudo xargs -0 sha256sum \
  | sudo tee "$MANIFEST" > /dev/null

sudo chown "${SIGN_USER}:${SIGN_GROUP}" "$MANIFEST"
chmod 644 "$MANIFEST"

echo "==> Signing..."
gpg --detach-sign --armor "$MANIFEST"

sudo chown root:root "$MANIFEST" "$SIG"
sudo chmod 644 "$MANIFEST" "$SIG"

echo "==> Verifying..."
sudo sha256sum -c "$MANIFEST" >/dev/null
gpg --verify "$SIG" "$MANIFEST" >/dev/null

echo "✅ LKG COMPLETE"
echo "payload:  $PAYLOAD_DIR"
echo "manifest: $MANIFEST"
echo "sig:      $SIG"
