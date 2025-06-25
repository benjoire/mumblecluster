#!/bin/bash
# syncstream.sh – Git push helper for SYNCSTREAM

cd "$(dirname "$0")"/..  # Moves to ~/Documents/MumbleCluster/github

echo "📦 Staging SYNCSTREAM changes..."
git add syncstream/ sandbox/ production/

echo "💬 Commit message:"
read -p "📝 > " COMMIT_MSG

git commit -m "$COMMIT_MSG"

echo "🚀 Pushing to GitHub..."
git push origin main

echo "✅ Push complete. 🍌🧠"
