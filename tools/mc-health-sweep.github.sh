#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# MumbleCluster GitHub-safe health sweep
# Public-safe derivative snapshot. Summary-rich, topology-light, secret-free.

need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency: $1" >&2; exit 1; }; }
log() { echo "[mc-health-sweep.github] $*"; }

need kubectl
need date
need sha256sum
need find
need sort
need xargs
need sed
need awk
need python3

MC_ROOT="${MC_ROOT:-/data/github/mumblecluster}"
MC_STATE="${MC_STATE:-${MC_ROOT}/state}"
MC_SNAP_DIR="${MC_SNAP_DIR:-${MC_ROOT}/cluster_snapshots}"
SWEEP_IDENTITY="${SWEEP_IDENTITY:-GHSAFE}"
SWEEP_DATE="${SWEEP_DATE:-$(date -u +%Y-%m-%d_%H-%M-%S)}"
PAYLOAD_DIR="${PAYLOAD_DIR:-${MC_SNAP_DIR}/${SWEEP_IDENTITY}-${SWEEP_DATE}}"
SEAL_DIR="${SEAL_DIR:-${MC_SNAP_DIR}/_seals}"
SKIP_TAR="${SKIP_TAR:-0}"

mkdir -p "$PAYLOAD_DIR" "$SEAL_DIR"
cd "$PAYLOAD_DIR"

log "payload=$PAYLOAD_DIR"

sanitize_text() {
  sed -E \
    -e 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<redacted-ip>/g' \
    -e 's/([A-Fa-f0-9]{1,4}:){2,}[A-Fa-f0-9]{1,4}/<redacted-ipv6>/g'
}

# ---- Public-safe summaries ----
log "summary exports"
kubectl get nodes > nodes.summary.txt
kubectl get ingress -A > ingress.summary.txt
kubectl get ingressclass > ingressclass.summary.txt
kubectl get svc -A > services.summary.txt
kubectl -n kube-system get pods -o wide | egrep 'etcd-|kube-apiserver-|kube-controller-manager-|kube-scheduler-|cilium|traefik' > control-plane.summary.txt || true
kubectl version > kubectl_version.txt 2>&1 || true

# Traefik-only ingress doctrine snapshot
mkdir -p ingress
kubectl get ingress -A -o yaml > ingress/ingress_all.raw.yaml
kubectl get ingressclass -o yaml > ingress/ingressclass.raw.yaml
kubectl -n traefik get deploy,svc -o yaml > ingress/traefik_core.raw.yaml 2>/dev/null || true
kubectl -n poc get ingress -o yaml > ingress/poc_ingress.raw.yaml 2>/dev/null || true

# ---- Build redacted public YAMLs ----
python3 - <<'PY'
from pathlib import Path
import re
base = Path('.')
for rel in [
    'ingress/ingress_all.raw.yaml',
    'ingress/ingressclass.raw.yaml',
    'ingress/traefik_core.raw.yaml',
    'ingress/poc_ingress.raw.yaml',
]:
    p = base / rel
    if not p.exists():
        continue
    txt = p.read_text(encoding='utf-8', errors='replace')
    txt = re.sub(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', '<redacted-ip>', txt)
    txt = re.sub(r'(?im)^(\s*(?:resourceVersion|uid|managedFields|creationTimestamp):).*$', r'\1 <redacted>', txt)
    txt = re.sub(r'(?im)^\s*clientToken:.*$', '  clientToken: <redacted>', txt)
    txt = re.sub(r'(?im)^\s*caBundle:.*$', '  caBundle: <redacted>', txt)
    out = p.with_name(p.name.replace('.raw', '.public'))
    out.write_text(txt, encoding='utf-8')
PY
rm -f ingress/*.raw.yaml

# ---- Narrative architecture notes ----
cat > architecture.summary.md <<'EOF2'
# MumbleCluster Public Health Snapshot

## Current ingress doctrine
- Public upstream edge: HEX22 NGINX
- Kubernetes ingress controller: Traefik
- Packaged ingress-nginx: retired

## Snapshot intent
This artifact is GitHub-safe and intentionally omits raw network inventory, WireGuard peer details, endpoint IP maps, port inventories, and secret-adjacent config.
EOF2

# ---- Public versions/doctrine ----
cat > versions.summary.txt <<EOF2
snapshot_utc=$(date -u +%FT%TZ)
repo_root=${MC_ROOT}
controller_plane_expected=3
EOF2

# ---- Optional sanitized route doctrine text ----
cat > network_doctrine.summary.txt <<'EOF2'
WG topology: /32 identity model
Transit model: BENQ hub / routed spoke design
Goal: topology summary only; no peer endpoints or private keys included
EOF2

# ---- Sanitize summaries with IP redaction ----
for f in nodes.summary.txt ingress.summary.txt ingressclass.summary.txt services.summary.txt control-plane.summary.txt kubectl_version.txt; do
  [[ -f "$f" ]] || continue
  sanitize_text < "$f" > "${f%.txt}.public.txt"
  rm -f "$f"
done

# ---- Manifest ----
BASE_NAME="${SWEEP_IDENTITY}-${SWEEP_DATE}"
MANIFEST="${SEAL_DIR}/${BASE_NAME}.sha256"
find "$PAYLOAD_DIR" -type f -print0 | sort -z | xargs -0 sha256sum > "$MANIFEST"
chmod 644 "$MANIFEST"

if [[ "$SKIP_TAR" != "1" ]]; then
  tar -czf "${PAYLOAD_DIR}.tar.gz" -C "$(dirname "$PAYLOAD_DIR")" "$(basename "$PAYLOAD_DIR")"
  sha256sum "${PAYLOAD_DIR}.tar.gz" > "${PAYLOAD_DIR}.tar.gz.sha256"
fi

log "done"
echo "payload:  $PAYLOAD_DIR"
echo "manifest: $MANIFEST"
[[ -f "${PAYLOAD_DIR}.tar.gz" ]] && echo "archive:  ${PAYLOAD_DIR}.tar.gz"
