#!/usr/bin/env bash

# Check if username is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <github-username>"
  exit 1
fi

USER="$1"
GISTS_DIR="$PWD/gists"

# Create the gists directory if it doesn't exist
mkdir -p "$GISTS_DIR"

# Get the list of gists using GitHub API
gists=$(curl -s "https://api.github.com/users/${USER}/gists")

# Parse each gist
echo "$gists" | jq -r '.[] | "\(.git_pull_url) \(.id) \(.description)"' | while IFS= read -r line; do
  git_url=$(echo "$line" | awk '{print $1}')
  gist_id=$(echo "$line" | awk '{print $2}')
  description=$(echo "$line" | cut -d' ' -f3-)

  # Clone into the gists directory
  dest_dir="${GISTS_DIR}/${gist_id}"
  git clone "$git_url" "$dest_dir"

  # Write the description
  echo "$description" > "${dest_dir}/description.txt"
done
