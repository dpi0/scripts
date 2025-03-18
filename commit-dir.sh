#!/bin/bash

# Global variable to store the input directory
input_dir=""

# Function to display usage information
usage() {
  echo "Usage: $0 /path/to/input/directory"
  exit 1
}

# Function to validate the input directory
validate_input_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
  fi
  cd "$dir" || exit
  if [ ! -d ".git" ]; then
    echo "Error: Directory '$dir' is not a Git repository."
    exit 1
  fi
  input_dir="$dir"
}

# Function to stage all changes, including deletions
stage_all_changes() {
  git add -A
}

# Function to commit files or directories with a detailed message
commit_item() {
  local item="$1"
  local timestamp
  timestamp=$(date +"%d %B %Y %H-%M-%S")
  local commit_message="Update $item $timestamp"
  local commit_body="Files changed:"

  # Generate the list of files changed
  while IFS= read -r file; do
    commit_body+="
    $file"
  done < <(git diff --cached --name-only -- "$item")

  # Combine the commit message and body
  local full_commit_message="$commit_message

$commit_body"

  # Commit the changes
  git commit -m "$full_commit_message" -- "$item"
}

# Function to commit subdirectories
commit_subdirectories() {
  for dir in */; do
    if [ -d "$dir" ]; then
      commit_item "$dir"
    fi
  done
}

# Function to commit individual files in the root directory
commit_root_files() {
  for file in .* *; do
    if [ -f "$file" ] && [ "$file" != "$(basename "$0")" ]; then
      commit_item "$file"
    fi
  done
}

# Main function to orchestrate the script's operations
main() {
  if [ -z "$1" ]; then
    usage
  fi

  validate_input_dir "$1"
  stage_all_changes
  commit_subdirectories
  commit_root_files
}

# Execute the main function with the provided argument
main "$1"
