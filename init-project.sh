#!/usr/bin/env bash

# Global variables for debugging
SCRIPT_NAME=$(basename "$0")
ERROR_LOG="error.log"
STATUS=0

# Function to display help menu
display_help() {
  echo "Usage: $SCRIPT_NAME [OPTIONS]"
  echo "Initialize a new project with common files."
  echo ""
  echo "Options:"
  echo "  -h, --help              Display this help menu and exit."
  echo "  -cc, --code-of-conduct  Include CODE_OF_CONDUCT.md in the project."
  echo ""
  exit 0
}

# Function to handle errors
handle_error() {
  local exit_code=$1
  local message="$2"
  STATUS=1
  echo "Error: $message (exit code: $exit_code)" | tee -a "$ERROR_LOG"
}

# Function to initialize git repository
initialize_git() {
  if [ -d ".git" ]; then
    echo "Git repository already initialized. Skipping."
  else
    git init || handle_error $? "Failed to initialize git repository"
  fi
}

# Function to create LICENSE file
create_license() {
  if [ -f "LICENSE" ]; then
    echo "LICENSE file already exists. Skipping."
  else
    curl -s https://bin.dpi0.cloud/BaTDwU > LICENSE || handle_error $? "Failed to download LICENSE file"
  fi
}

# Function to create README.md file
create_readme() {
  if [ -f "README.md" ]; then
    echo "README.md file already exists. Skipping."
  else
    echo "# $DIR_NAME" > README.md || handle_error $? "Failed to create README.md"
  fi
}

# Function to create .gitignore file
create_gitignore() {
  if [ -f ".gitignore" ]; then
    echo ".gitignore file already exists. Skipping."
  else
    touch .gitignore || handle_error $? "Failed to create .gitignore"
  fi
}

# Function to create CODE_OF_CONDUCT.md file
create_code_of_conduct() {
  if [ -f "CODE_OF_CONDUCT.md" ]; then
    echo "CODE_OF_CONDUCT.md file already exists. Skipping."
  else
    curl -s https://bin.dpi0.cloud/UptdPQ.md > CODE_OF_CONDUCT.md || handle_error $? "Failed to download CODE_OF_CONDUCT.md"
    sed -i "1s/repo_name/$DIR_NAME/" CODE_OF_CONDUCT.md || handle_error $? "Failed to update CODE_OF_CONDUCT.md"
  fi
}

# Parse command-line arguments
INCLUDE_CODE_OF_CONDUCT=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) display_help ;;
    -cc|--code-of-conduct) INCLUDE_CODE_OF_CONDUCT=true ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

DIR_NAME=$(basename "$PWD")

# Execute functions
initialize_git
create_license
create_readme
create_gitignore

if [ "$INCLUDE_CODE_OF_CONDUCT" = true ]; then
  create_code_of_conduct
fi

# Exit with the appropriate status code
exit $STATUS
