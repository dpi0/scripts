#!/bin/bash

# Pulls the latest changes from a specified GitHub repository using a fine-grained token

# Configuration
REPO_PATH="$HOME/1ec2-aws"  # Path to the local Git repository
BRANCH="main"             # Branch to pull changes from
GITHUB_USERNAME="dpi0"
GITHUB_REPO_NAME="1ec2-aws"
GITHUB_TOKEN="xyz"  # Fine-grained GitHub PAT
REMOTE_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO_NAME}.git"

# Ensure the repository exists, clone if it doesn't
if [[ ! -d "$REPO_PATH/.git" ]]; then
  echo "Repository not found. Cloning..."
  git clone --branch "$BRANCH" "$REMOTE_URL" "$REPO_PATH" || { echo "Failed to clone repository"; exit 1; }
fi

# Change to the repository directory
cd "$REPO_PATH" || exit 1

# Function to stop all Docker containers
stop_docker_containers() {
  echo "Stopping all running Docker containers..."
  docker ps -q | xargs -r docker stop
}

# Function to start all Docker containers
start_docker_containers() {
  echo "Starting all Docker containers..."
  docker ps -aq | xargs -r docker start
}

# Pull latest changes
# stop_docker_containers

echo "Fetching latest changes from the remote repository..."
git fetch --quiet origin "$BRANCH"

echo "Resetting local branch to match remote..."
git reset --hard "origin/$BRANCH"

echo "Cleaning up untracked files..."
git clean -fd

echo "Repository updated successfully!"

# start_docker_containers
