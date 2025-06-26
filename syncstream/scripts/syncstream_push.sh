#!/bin/bash

set -e

REPO_ROOT="$(dirname "$(realpath "$0")")/.."
cd "$REPO_ROOT" || exit 1

echo "[SYNCSTREAM] Navigating to: $REPO_ROOT"
echo "[SYNCSTREAM] Checking repo status..."
git status

echo "[SYNCSTREAM] Staging relevant files..."
git add SYNCSTREAM_sheet.ods scripts/ logs/ 2>/dev/null || true

# Clean up .~lock files manually
find . -name ".*~lock.*" -exec rm -f {} \;

echo "[SYNCSTREAM] Committing..."
git commit -m "🔄 Session 4: Sheet+Script updates, emoji grammar injected" || echo "No new changes to commit."

echo "[SYNCSTREAM] Rebasing from origin/main..."
git pull --rebase origin main || {
    echo "[SYNCSTREAM] Rebase failed. Applying stash workaround..."
    git stash
    git pull --rebase origin main
    git stash pop || echo "[SYNCSTREAM] No stash to pop."
}

echo "[SYNCSTREAM] Pushing to remote..."
git push origin main

echo "[SYNCSTREAM] ✅ Push successful."
