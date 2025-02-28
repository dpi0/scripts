#!/bin/bash

# pulls, adds everything, auto commits, then pushes to the specified repo using the fine grained token
# using a cron job every 72h on 2 am - 0 2 */3 * *
# don't know how useful it is

# Configuration
REPO_PATH="$HOME/server"        # Path to the local Git repository
BRANCH="main"                        # Branch to push changes to
COMMIT_MESSAGE="Push all files $(date +"%d %b %Y %H:%M")"
GITHUB_USERNAME="dpi0"
GITHUB_REPO_NAME="1ec2-aws"
GITHUB_TOKEN="xyz" # Fine-grained GitHub PAT

# Change directory to the repository
cd "$REPO_PATH" || { echo "Repository path not found"; exit 1; }

# Function to stop all Docker containers
stop_docker_containers() {
    echo "Stopping all Docker containers..."
    docker stop $(docker ps -aq)
}

# Function to start all Docker containers
start_docker_containers() {
    echo "Starting all Docker containers..."
    docker start $(docker ps -aq)
}

cd "$REPO_PATH" || { echo "Repository path not found"; exit 1; }

# Check for changes
if [[ -n $(git status --porcelain) ]]; then
    stop_docker_containers

    echo "Changes detected, preparing to push..."

    # Add changes
    git add .

    # Commit changes
    git commit -m "$COMMIT_MESSAGE"

    # Push changes
    git push https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/$GITHUB_REPO_NAME.git "$BRANCH"

    echo "Changes pushed successfully!"

    start_docker_containers
else
    echo "No changes detected. Exiting."
fi
