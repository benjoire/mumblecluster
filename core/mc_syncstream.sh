#!/usr/bin/env bash
set -euo pipefail

echo "[mc_syncstream] ingesting runs..."

python3 "${MC_ROOT}/tools/mc_syncstream_ingest.py"

echo "[mc_syncstream] done"
