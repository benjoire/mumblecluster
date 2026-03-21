set -euo pipefail
# =========================
# MumbleCluster Run Wrapper
# =========================
# Canonical evidence-first execution wrapper.
#
# Usage:
#   mc_run.sh "Title" -- <command> [args...]
#
# Environment:
#   MC_PHASE        optional (e.g. Phase-1.6, Phase-2)
#   MC_SCOPE        optional (e.g. node0<->hetzner)
#   MC_OPERATOR     optional
#   MC_CAPTURE      full|minimal|none   (default: full)
#   MC_NO_PROMPT    1 = do not open notes editor
#
# Target scripts SHOULD respect OUT_DIR.

MC_ROOT="${MC_ROOT:-/home/celvin__1/Documents/MumbleCluster}"
MC_BLUEPRINT="${MC_BLUEPRINT:-${MC_ROOT}/_blueprint}"
MC_RUNS_DIR="${MC_RUNS_DIR:-${MC_BLUEPRINT}/_runs}"

MC_PHASE="${MC_PHASE:-}"
MC_SCOPE="${MC_SCOPE:-}"
MC_OPERATOR="${MC_OPERATOR:-${USER:-unknown}}"
MC_CAPTURE="${MC_CAPTURE:-full}"
MC_NO_PROMPT="${MC_NO_PROMPT:-0}"

MC_AUTOSYNC="${MC_AUTOSYNC:-1}"  # 1=auto export runs index CSV when run is COMPLETE
MC_SYNC_TOOL="${MC_SYNC_TOOL:-/home/celvin__1/Documents/MumbleCluster/github/repositories/mumble-cluster/tools/mc_syncstream_ingest.py}"

die() { echo "ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }

need kubectl
need date
need sed
need tr

usage() {
  cat >&2 <<'EOF'
Usage:
  mc_run.sh "Title" -- <command> [args...]
  mc_run.sh --title "Title" -- <command> [args...]
  mc_run.sh --title="Title" -- <command> [args...]
  mc_run.sh -t "Title" -- <command> [args...]
EOF
  exit 1
}

[[ $# -ge 3 ]] || usage

# Back-compat fast path: mc_run.sh "Title" -- cmd...
if [[ "${1:-}" != -* ]]; then
  TITLE="$1"; shift
  [[ "${1:-}" == "--" ]] || die "Expected '--' after title"
  shift
else
  TITLE=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title)
        shift
        [[ $# -gt 0 ]] || die "--title requires a value"
        TITLE="$1"
        shift
        ;;
      --title=*)
        TITLE="${1#--title=}"
        shift
        ;;
      -t)
        shift
        [[ $# -gt 0 ]] || die "-t requires a value"
        TITLE="$1"
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        die "Unknown option: $1 (expected --title/-t and then --)"
        ;;
    esac
  done

  [[ -n "$TITLE" ]] || die "Missing title (use --title/-t or positional title)"
  [[ $# -ge 1 ]] || die "Missing command after --"
fi

CMD=( "$@" )


# ----------------
CMD_STR="$(printf '%q ' "${CMD[@]}")"
CMD_STR="${CMD_STR% }"
export CMD_STR

CMD_JSON="$(python3 - <<'PY'
import json, os
print(json.dumps(os.environ["CMD_STR"]))
PY
)"
# ----------------

TS_UTC="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
TS_DIR="$(date -u +'%Y-%m-%d_%H-%M-%S')"

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-+/-/g' \
    | cut -c1-72
}

SLUG="$(slugify "$TITLE")"
RUN_DIR="${MC_RUNS_DIR}/${TS_DIR}__${SLUG}"

FACTS="${RUN_DIR}/facts"
RAW="${RUN_DIR}/raw"
DIFF="${RUN_DIR}/diff"

mkdir -p "$FACTS" "$RAW" "$DIFF"

SUMMARY="${RUN_DIR}/SUMMARY.md"
NOTES="${RUN_DIR}/notes.md"
RECORD="${RUN_DIR}/run_record.json"
STATUS="${RUN_DIR}/status.txt"

echo "INCOMPLETE" > "$STATUS"

# Resolve hetzner dynamically
HETZ_NODE="$(kubectl get nodes -o name | sed 's#node/##' | grep -E '^hetzner' | head -n1 || true)"
# Resolve rapunzel dynamically
RAPUNZEL_NODE="$(kubectl get nodes -o name | sed 's#node/##' | grep -E '^node0' | head -n1 || true)"

cap() {
  local file="$1"; shift
  {
    echo "\$ $*"
    "$@"
    echo
  } > "$file" 2>&1 || true
}

# ----------------
# PRE-CAPTURE
# ----------------
if [[ "$MC_CAPTURE" == "full" ]]; then
  cap "$FACTS/pre_nodes.txt" kubectl get nodes -o wide
  cap "$FACTS/pre_pods.txt"  kubectl get pods -A -o wide
  cap "$FACTS/pre_svc.txt"   kubectl get svc -A -o wide
  cap "$FACTS/pre_ep.txt"    kubectl get endpoints -A -o wide
fi

# ----------------
# EXECUTION
# ----------------
export OUT_DIR="$RAW"

cat > "$SUMMARY" <<EOF
# MumbleCluster Run

- Title: $TITLE
- Timestamp (UTC): $TS_UTC
- Phase: ${MC_PHASE:-unspecified}
- Scope: ${MC_SCOPE:-unspecified}
- Operator: $MC_OPERATOR
- Controller node: ${RAPUNZEL_NODE:-unknown}

## Command
\`${CMD[*]}\`
EOF

echo "==> RUN: $RUN_DIR"
echo "==> CMD: ${CMD[*]}"

set +e
"${CMD[@]}" 2>&1 | tee "$RAW/action_stdout_stderr.txt"
RC="${PIPESTATUS[0]}"
set -e

echo "- Exit code: $RC" >> "$SUMMARY"

# ----------------
# POST-CAPTURE
# ----------------
if [[ "$MC_CAPTURE" == "full" ]]; then
  cap "$FACTS/post_nodes.txt" kubectl get nodes -o wide
  cap "$FACTS/post_pods.txt"  kubectl get pods -A -o wide
  diff -u "$FACTS/pre_nodes.txt" "$FACTS/post_nodes.txt" > "$DIFF/nodes.diff" 2>/dev/null || true
  diff -u "$FACTS/pre_pods.txt"  "$FACTS/post_pods.txt"  > "$DIFF/pods.diff"  2>/dev/null || true
fi

# ----------------
# RECORD
# ----------------
tmp_record="${RECORD}.tmp"
cat > "$tmp_record" <<JSON
{
  "schema": "mc.run_record.v1",
  "timestamp_utc": "$TS_UTC",
  "title": "$TITLE",
  "slug": "$SLUG",
  "phase": "$MC_PHASE",
  "scope": "$MC_SCOPE",
  "operator": "$MC_OPERATOR",
  "controller_node": "$RAPUNZEL_NODE",
  "hetzner_node": "$HETZ_NODE",
  "command": ${CMD_JSON},
  "exit_code": $RC,
  "run_dir": "$RUN_DIR",
  "status": "INCOMPLETE"
}
JSON
mv -f "$tmp_record" "$RECORD"

# ----------------
# NOTES GATE
# ----------------
if [[ ! -f "$NOTES" ]]; then
cat > "$NOTES" <<'EOF'
# Notes (MANDATORY)

- Intent:
- What changed:
- Result:
- Follow-up:
EOF
fi

if [[ "$MC_NO_PROMPT" != "1" ]]; then
  "${EDITOR:-nano}" "$NOTES"
fi

if grep -Eq "Intent: .+|What changed: .+|Result: .+|Follow-up: .+" "$NOTES"; then
  echo "COMPLETE" > "$STATUS"
  sed -i 's/"status": "INCOMPLETE"/"status": "COMPLETE"/' "$RECORD"
fi

echo "==> Status: $(cat "$STATUS")"

# ----------------
# AUTO-SYNCSTREAM EXPORT (optional)
# ----------------
if [[ "${MC_AUTOSYNC}" == "1" ]] && [[ "$(cat "$STATUS")" == "COMPLETE" ]]; then
  if [[ -x "${MC_SYNC_TOOL}" ]]; then
    echo "==> Auto-export Runs Index CSV via: ${MC_SYNC_TOOL}"
    # Capture export output inside the run evidence
    set +e
    "${MC_SYNC_TOOL}" > "${RAW}/syncstream_export.txt" 2>&1
    SYNC_RC=$?
    set -e
    if [[ $SYNC_RC -ne 0 ]]; then
      echo "WARN: SYNCSTREAM export failed (rc=$SYNC_RC). See: ${RAW}/syncstream_export.txt" >&2
    fi
  else
    echo "WARN: MC_SYNC_TOOL not executable or missing: ${MC_SYNC_TOOL}" >&2
  fi
fi

exit "$RC"
