#!/bin/bash
# push_repo.sh — Generalized Git push for any repo folder

# Set working directory to the parent of this script if not run from there
cd "$(dirname "$0")/.." || exit 1

REPO_DIR=$(pwd)
DEFAULT_COMMIT_MSG="🔄 Auto commit from $(basename "$REPO_DIR") at $(date +'%Y-%m-%d %H:%M')"

# Optional commit message passed as args
COMMIT_MSG="$*"
if [ -z "$COMMIT_MSG" ]; then
  echo "[INFO] No commit message provided. Using default."
  COMMIT_MSG="$DEFAULT_COMMIT_MSG"
fi

echo "[INFO] Working in: $REPO_DIR"
echo "[INFO] Commit message: $COMMIT_MSG"

# Stage all tracked + new changes
git add .

# Show changes before committing
git status
git diff --cached

# Pull with rebase to avoid conflicts
git pull --rebase

# Commit and push
git commit -m "$COMMIT_MSG"
git push origin main

echo "[SUCCESS] Changes pushed from: $REPO_DIR"
