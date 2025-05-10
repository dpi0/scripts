#!/usr/bin/env bash

# pulls, adds everything, auto commits, then pushes to the specified repo using the fine grained token
# using a cron job every 72h on 2 am - 0 2 */3 * *
# don't know how useful it is

REPO_PATH="$HOME/server"
BRANCH="main"
COMMIT_MESSAGE="Push all files $(TZ=Asia/Kolkata date +"%d %b %Y %H:%M")"
GITHUB_USERNAME="dpi0"
GITHUB_REPO_NAME="1ec2-aws"
GITHUB_TOKEN="$GITHUB_PULL_PUSH_REPO_TOKEN"

cd "$REPO_PATH" || {
  echo "Repository path not found"
  exit 1
}

cd "$REPO_PATH" || {
  echo "Repository path not found"
  exit 1
}

# Check for changes
if [[ -n $(git status --porcelain) ]]; then
  echo "Changes detected, preparing to push..."
  git add .
  git commit -m "$COMMIT_MESSAGE"
  git push https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/$GITHUB_REPO_NAME.git "$BRANCH"
  echo "Changes pushed successfully!"
else
  echo "No changes detected. Exiting."
fi
