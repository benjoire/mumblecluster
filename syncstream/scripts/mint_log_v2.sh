#!/bin/bash
# mint_log_v2.sh — Generate Log v2 entries using gum prompts

LOGFILE="/home/celvin__1/Documents/MumbleCluster/github/syncstream/logs/syncstream_log.csv"

# Check for gum
if ! command -v gum &> /dev/null; then
    echo "'gum' not found. Please install it: https://github.com/charmbracelet/gum"
    exit 1
fi

# Prompt user for each log field
TIMESTAMP=$(gum input --placeholder "YYYY-MM-DD HH:MM" --prompt "Session Timestamp:")
BLOCK=$(gum choose "Zen" "DUTY" "Bootcamp" "Weekend")
ACTIVITY=$(gum input --placeholder "Describe what happened" --prompt "Activity:")
STATUS=$(gum choose "🧪" "⚙️" "🧬")
TASKREF=$(gum input --placeholder "001, 002, etc." --prompt "Task Reference:")
OWNER=$(gum choose "Ben" "Deniz" "Shared")
SUMMARY=$(gum input --placeholder "Short summary of changes" --prompt "Change Summary:")
TAB=$(gum input --placeholder "e.g. Git layer, Schedule" --prompt "Linked Sheet Tab:")
NEXT=$(gum input --placeholder "e.g. push update, start new task" --prompt "Next Action Proposed:")

# Write to log
echo -e "${TIMESTAMP}\t${BLOCK}\t${ACTIVITY}\t${STATUS}\t${TASKREF}\t${OWNER}\t${SUMMARY}\t${TAB}\t${NEXT}" >> "$LOGFILE"

echo "Log entry added to $LOGFILE"
