#!/usr/bin/env bash
set -euo pipefail

MC_ROOT="${MC_ROOT:-/data/github/mumblecluster}"
MC_STATE="${MC_STATE:-${MC_ROOT}/state}"

MODE="${1:-manual}"
OUT="${MC_STATE}/health_${MODE}_$(date -u +%s).json"

mkdir -p "${MC_STATE}"

kubectl get nodes -o wide > /tmp/nodes.txt
kubectl get pods -A -o wide > /tmp/pods.txt

STATUS="HEALTHY"

if grep -q "NotReady" /tmp/nodes.txt; then
  STATUS="DEGRADED"
fi

if grep -q "CrashLoopBackOff" /tmp/pods.txt; then
  STATUS="DEGRADED"
fi

cat > "$OUT" <<EOF
{
  "timestamp": "$(date -u +%FT%TZ)",
  "mode": "$MODE",
  "status": "$STATUS"
}
EOF

echo "[mc_health] $STATUS → $OUT"
