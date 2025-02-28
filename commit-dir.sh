#!/usr/bin/env bash

# Function to display usage information
usage() {
  echo "Usage: $0 <directory>"
  exit 1
}

# Function to check if a directory is a git repository
is_git_repo() {
  if [ ! -d "$1/.git" ]; then
    echo "Directory '$1' is not a git repository."
    exit 1
  fi
}

# Function to commit changes in a directory
commit_directory() {
  local dir=$1
  local dir_name=${dir%/}

  # Stage changes in the directory
  git add "$dir_name" > /dev/null 2>&1

  # Check if there are any changes to commit
  if ! git diff-index --quiet HEAD -- "$dir_name"; then
    # Get the current date and time
    local current_date=$(date +"%d-%m-%Y %H:%M")

    # Get the list of staged files
    local files_changed=$(git diff --cached --name-only -- "$dir_name" | sed 's/^/    /')

    # Create the commit message with the file list
    local commit_message="Update $dir_name $current_date\n\nFiles changed:\n$files_changed"

    # Commit with the commit message from a file
    echo -e "$commit_message" | git commit -F - > /dev/null 2>&1

    # Echo the committed directory
    echo "Committed directory: $dir_name"
  else
    # Unstage the changes if there's nothing to commit
    git reset "$dir_name" > /dev/null 2>&1
  fi
}

# Check if a directory name was provided as an argument
if [ "$#" -ne 1 ]; then
  usage
fi

# Store the directory name from the argument
target_dir="$1"

# Check if the specified directory exists
if [ ! -d "$target_dir" ]; then
  echo "Directory '$target_dir' does not exist."
  exit 1
fi

# Check if the specified directory is a git repository
is_git_repo "$target_dir"

# Change to the specified directory
cd "$target_dir" || exit

# Loop through each directory within the specified directory, including hidden ones
shopt -s dotglob
for dir in */; do
  # Check if it's a directory
  if [ -d "$dir" ]; then
    commit_directory "$dir"
  fi
done
