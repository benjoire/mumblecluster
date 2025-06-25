#!/bin/bash
# gh-toolkit.sh — GitHub CLI helper with gum menu (emoji-free)

# Check if 'gum' is installed
if ! command -v gum &> /dev/null; then
    echo "'gum' not found. Please install it: https://github.com/charmbracelet/gum"
    exit 1
fi

# Menu prompt
CHOICE=$(gum choose --cursor ">" --limit 1 \
  "View repo in browser" \
  "List branches" \
  "Create pull request" \
  "Open in github.dev" \
  "Auth status" \
  "Exit")

# Handle selection
case "$CHOICE" in
  "View repo in browser")
    gh repo view --web
    ;;
  "List branches")
    gh repo view --json refs --jq '.refs[].name'
    ;;
  "Create pull request")
    gh pr create --title "SYNCSTREAM Patch" --body "Log or README update"
    ;;
  "Open in github.dev")
    REPO=$(basename "$(pwd)")
    xdg-open "https://github.dev/benjoire/$REPO"
    ;;
  "Auth status")
    gh auth status
    ;;
  "Exit")
    echo "Exiting GitHub toolkit."
    ;;
  *)
    echo "Unknown selection."
    ;;
esac
