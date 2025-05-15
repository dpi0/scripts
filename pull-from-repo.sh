#!/usr/bin/env bash

# Pulls the latest changes from a specified GitHub repository using a fine-grained token

REPO_PATH="$HOME/1ec2-aws"
BRANCH="main"
GITHUB_USERNAME="dpi0"
GITHUB_REPO_NAME="1ec2-aws"
GITHUB_TOKEN="$GITHUB_PULL_PUSH_REPO_TOKEN"
REMOTE_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO_NAME}.git"

# Ensure the repository exists, clone if it doesn't
if [[ ! -d "$REPO_PATH/.git" ]]; then
	echo "Repository not found. Cloning..."
	git clone --branch "$BRANCH" "$REMOTE_URL" "$REPO_PATH" || {
		echo "Failed to clone repository"
		exit 1
	}
fi

cd "$REPO_PATH" || exit 1

echo "Fetching latest changes from the remote repository..."
git fetch --quiet origin "$BRANCH"

echo "Resetting local branch to match remote..."
git reset --hard "origin/$BRANCH"

echo "Cleaning up untracked files..."
git clean -fd

echo "Repository updated successfully!"
