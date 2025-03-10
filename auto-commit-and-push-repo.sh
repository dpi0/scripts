#!/usr/bin/env bash

# Global variables
SCRIPT_DIR="$HOME/scripts"
COMMIT_SCRIPT="$SCRIPT_DIR/commit-dir.sh"

REPOS=(
  "$HOME/.dotfiles"
  "$HOME/scripts"
  "$HOME/sh"
)

# Execute commit script for each directory
for dir in "${REPOS[@]}"; do
  "$COMMIT_SCRIPT" "$dir"
done

# Push changes for each repo
for dir in "${REPOS[@]}"; do
  if [ -d "$dir/.git" ]; then # Ensure it's a git repository
    git -C "$dir" push origin main || echo "Failed to push $dir"
  else
    echo "Skipping $dir (not a git repository)"
  fi
done
