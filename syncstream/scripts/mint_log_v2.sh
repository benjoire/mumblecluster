#!/bin/bash
# mint_log_v2.sh — Generalized Log v2 generator (interactive + piped)

DEFAULT_LOGFILE="/home/celvin__1/Documents/MumbleCluster/github/syncstream/logs/syncstream_log.csv"
LOGFILE="$DEFAULT_LOGFILE"

# Allow --logfile override
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --logfile) LOGFILE="$2"; shift ;;
  esac
  shift
done

# Check for gum
if ! command -v gum &> /dev/null; then
  echo "'gum' not found. Please install: https://github.com/charmbracelet/gum"
  exit 1
fi

# Allow pipe-mode if stdin is not tty
if [ ! -t 0 ]; then
  while IFS= read -r line; do
    echo -e "$line" >> "$LOGFILE"
  done
  echo "✅ Log entries piped into $LOGFILE"
  exit 0
fi

# Interactive prompts
TIMESTAMP=$(gum input --placeholder "$(date '+%Y-%m-%dT%H:%M:%S')" --prompt "Session Timestamp:")
BLOCK=$(gum input --placeholder "Session 5" --prompt "Block (Schedule):")
ACTIVITY=$(gum input --placeholder "Describe activity..." --prompt "Activity:")
STATUS=$(gum choose "🟩" "🧪" "🧬" "✅" "⚠️" "❌")
TASKREF=$(gum input --placeholder "S5-T5" --prompt "Task Reference:")
OWNER=$(gum choose "Ben" "Deniz" "Shared")
SUMMARY=$(gum input --placeholder "Short summary..." --prompt "Change Summary:")
TAB=$(gum input --placeholder "e.g. Tasks, Git layer" --prompt "Linked Sheet Tab:")
NEXT=$(gum input --placeholder "Next step..." --prompt "Next Action Proposed:")

# Output to log
echo -e "${TIMESTAMP}	${BLOCK}	${ACTIVITY}	${STATUS}	${TASKREF}	${OWNER}	${SUMMARY}	${TAB}	${NEXT}" >> "$LOGFILE"
echo "✅ Log entry added to $LOGFILE"
