#!/bin/bash
cd "$(dirname "$0")/../" || exit
echo "Pulling remote changes with rebase..."
git pull --rebase origin main

echo "Staging changes..."
git add syncstream/

echo "Commit message:"
read -r COMMIT_MSG
git commit -m "$COMMIT_MSG"

echo "Pushing to GitHub..."
git push origin main
echo "Push complete."
