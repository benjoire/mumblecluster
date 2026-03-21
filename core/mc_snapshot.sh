#!/usr/bin/env bash
set -euo pipefail

MC_ROOT="${MC_ROOT:-/data/github/mumblecluster}"
MC_STATE="${MC_STATE:-${MC_ROOT}/state}"
MC_SNAP_DIR="${MC_SNAP_DIR:-${MC_ROOT}/cluster_snapshots}"

TITLE="${1:-snapshot}"
TS="$(date -u +%Y-%m-%d_%H-%M-%S)"

export LKG_BASE="${MC_SNAP_DIR}"
export LKG_DATE="$TS"
export LKG_IDENTITY="$TITLE"

echo "[mc_snapshot] creating LKG..."

"${MC_ROOT}/tools/lkg-seal.sh"

echo "[mc_snapshot] done"
