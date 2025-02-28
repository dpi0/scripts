#!/usr/bin/env bash

# Create the directory if it doesn't exist
OUTPUT_DIR="$HOME/Screenshots/recordings/"
mkdir -p "$OUTPUT_DIR"

# Generate the timestamp and filename
timestamp=$(date +'%d-%m-%Y_%H-%M-%S') 
filename="$timestamp.cast"
filepath="$OUTPUT_DIR/$filename"

# Record the terminal session
asciinema rec --cols=120 --rows=30 --title="terminal" "$filepath"

# After recording, convert to GIF
agg --theme dracula --font-size 27 --font-family "JetBrainsMono NF" "$filepath" "${filepath%.cast}.gif"

# Prompt to upload the GIF
read -p "Do you want to upload ${filepath%.cast}.gif to imgbb? (y/n): " upload_choice
echo

if [[ "$upload_choice" == "y" || "$upload_choice" == "" ]]; then
    img-upload.sh "${filepath%.cast}.gif"
fi

# Prompt to remove the original recording file
read -p "Do you want to remove the original recording file ${filepath}? (y/n): " remove_choice
echo

if [[ "$remove_choice" == "y" || "$remove_choice" == "" ]]; then
    rm "$filepath"
    echo "Removed ${filepath}"
else
    echo "Keeping ${filepath}"
fi
