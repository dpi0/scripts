#!/usr/bin/env bash

# Default values
DEFAULT_THEME="gruvbox"
THEME="$DEFAULT_THEME"
FILE_PATH=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --theme) THEME="$2"; shift ;;
        *) FILE_PATH="$1" ;;
    esac
    shift
done

# Check if file path is provided
if [ -z "$FILE_PATH" ]; then
    echo "Error: No file path provided."
    echo "Usage: $0 [--theme THEME] /path/to/file"
    exit 1
fi

# Extract file name without path
FILE_NAME=$(basename "$FILE_PATH")

# Get the current time and date in the required formats
TIME_HHMMSS=$(date +%H-%M-%S)
DATE_DDMMM=$(date +%d-%b)

# Construct the output file name
OUTPUT_FILE="${FILE_NAME} (${TIME_HHMMSS}) (${DATE_DDMMM}).png"

# Set the output directory
OUTPUT_DIR="$HOME/Screenshots"
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

# Execute codeshot with the provided or default theme
freeze \
    -t "$THEME" \
    "$FILE_PATH" \
    --padding 20 \
    --font.family "JetBrains Mono Nerd Font" \
    --font.size 16 \
    --line-height 1.4 \
    --show-line-numbers \
    --window \
    --output "$OUTPUT_PATH"
    # --border.radius 8 \

# Upload the generated image using img-upload
img-upload.sh "$OUTPUT_PATH"
