#!/bin/bash
# syncstream.sh – scoped Git push for syncstream/

REPO_DIR="/home/celvin__1/Documents/MumbleCluster/github"
cd "$REPO_DIR/syncstream" || exit

echo "📦 Staging changes in syncstream/"
git add .

echo "📝 Commit message:"
read -r COMMIT_MSG

git commit -m "$COMMIT_MSG"
git push origin main

echo "✅ syncstream push complete."
