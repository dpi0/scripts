#!/usr/bin/env bash

# Global variables
THEME="gruvbox"
OUTPUT_DIR="$HOME/Screenshots"
TIME_HHMMSS=$(date +%H-%M-%S)
DATE_DDMMM=$(date +%d-%b)

# Parse arguments
[[ "$1" == "--theme" ]] && {
  THEME="$2"
  shift 2
}
FILE_PATH="$1"

# Validate file path
[[ -z "$FILE_PATH" ]] && {
  echo "Usage: $0 [--theme THEME] /path/to/file"
  exit 1
}

# Generate output file name
OUTPUT_FILE="$(basename "$FILE_PATH") ($TIME_HHMMSS) ($DATE_DDMMM).png"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

# Execute codeshot with theme
freeze -t "$THEME" "$FILE_PATH" --padding 20 --font.family "JetBrains Mono Nerd Font" \
  --font.size 16 --line-height 1.4 --show-line-numbers --window --output "$OUTPUT_PATH"

# Upload the image
pst "$OUTPUT_PATH"
