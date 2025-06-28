#!/bin/bash
# sandbox_push.sh — Push changes in sandboxed git projects

# Set target repo path
TARGET="$1"
if [ -z "$TARGET" ]; then
  echo "Usage: ./sandbox_push.sh <path-to-sandbox-repo>"
  exit 1
fi

cd "$TARGET" || exit 1

REPO_DIR=$(pwd)
DEFAULT_COMMIT_MSG="🔬 Sandbox commit from $(basename "$REPO_DIR") at $(date +'%Y-%m-%d %H:%M')"

# Optional commit message from user
read -rp "Enter commit message (leave empty for default): " USER_MSG
COMMIT_MSG="${USER_MSG:-$DEFAULT_COMMIT_MSG}"

# Stage, commit, and push
git add .
git pull --rebase
git commit -m "$COMMIT_MSG"
git push origin main

echo "[SUCCESS] Sandbox pushed from: $REPO_DIR"
