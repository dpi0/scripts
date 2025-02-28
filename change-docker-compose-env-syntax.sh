#!/usr/bin/env bash

# Function to display usage
usage() {
  echo "Usage: $0 [-i|--input <input_file_pattern>] [-r|--recursive]"
  echo
  echo "Options:"
  echo "  -i, --input       Specify the input file or file pattern (required)"
  echo "  -r, --recursive   Recursively search and process all matching files using the 'fd' tool"
  echo
  echo "Examples:"
  echo "  $0 -i myfile.yaml              # Process 'myfile.yaml' in the current directory"
  echo "  $0 -i *.yaml -r                # Recursively process all '.yaml' files using 'fd'"
  echo
  exit 1
}

# Parse command line arguments
recursive=false
input_file=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--input) input_file="$2"; shift ;;
    -r|--recursive) recursive=true ;;
    *) usage ;;
  esac
  shift
done

# Check if input file is provided
if [ -z "$input_file" ]; then
  usage
fi

# Function to process a single file
process_file() {
  local file="$1"
  echo "Processing file: $file"
  
  # Temporary file to store the changes
  local temp_file=$(mktemp)

  # Read the input file and process the environment section
  while IFS= read -r line; do
    if [[ $line == *"environment:"* ]]; then
      echo "$line" >> "$temp_file"
      while IFS= read -r env_line; do
        if [[ $env_line == *"-"* ]]; then
          # Strip the dash and then process key=value
          key=$(echo "$env_line" | sed 's/-//' | cut -d'=' -f1 | tr -d ' ')
          value=$(echo "$env_line" | cut -d'=' -f2 | tr -d ' ')
          echo "      $key: $value" >> "$temp_file"  # Correct indentation without dash
        else
          echo "$env_line" >> "$temp_file"
          break
        fi
      done
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$file"

  # Display the changes to the user
  echo "The following changes will be made to $file:"

  # Check if delta is installed, otherwise fallback to diff
  if command -v delta &> /dev/null; then
    delta --side-by-side "$file" "$temp_file"
  else
    echo "delta not found, falling back to diff."
    diff -u "$file" "$temp_file" | while IFS= read -r line; do
      if [[ $line == -* ]]; then
        echo -e "\e[31m$line\e[0m"  # Red for removed lines
      elif [[ $line == +* ]]; then
        echo -e "\e[32m$line\e[0m"  # Green for added lines
      else
        echo "$line"
      fi
    done
  fi

  # Ask for confirmation before overwriting the file
  read -p "Do you want to overwrite $file with the new changes? (y/n): " confirm
  if [[ $confirm == "y" || $confirm == "Y" ]]; then
    mv "$temp_file" "$file"
    echo "File overwritten successfully."
  else
    echo "Changes not applied. Temporary file saved as $temp_file."
  fi
}

# Export the function so it can be used in subshells
export -f process_file

# If recursive is set, use fd to find files, otherwise just process the single file
if $recursive; then
  # Use 'fd' to find all matching files and process them
  fd -e "${input_file##*.}" -g "$input_file" -x bash -c 'process_file "$1"' _ {}
else
  process_file "$input_file"
fi
