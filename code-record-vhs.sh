#!/usr/bin/env bash

# Set the current time and date formats
TIME_HHMMSS=$(date +%H-%M-%S)
DATE_DDMMM=$(date +%d-%b)

# Construct the output file name
FILE_NAME="code-recording"  # You can change this as needed
OUTPUT_FILE="${FILE_NAME}_(${TIME_HHMMSS})_(${DATE_DDMMM}).gif"

# Record the terminal session using VHS
vhs record > "${FILE_NAME}_${TIME_HHMMSS}_${DATE_DDMMM}.tape"

# Define the output GIF file path
gif_file="$HOME/Screenshots/Recordings/${OUTPUT_FILE}"

# Add configuration text to the top of the generated .tape file
tape_file=~/"${FILE_NAME}_${TIME_HHMMSS}_${DATE_DDMMM}.tape"
echo -e "Output \"$gif_file\"\nSet FontSize 20\nSet FontFamily \"JetBrainsMono Nerd Font\"\nSet Width 800\nSet Height 600\nSet LineHeight 1.3\nSet Theme \"Hyper\"\nSet Padding 20\nSet WindowBar Colorful\nSet Framerate 60\n$(cat "$tape_file")" > "$tape_file"

# Run the VHS command on the modified .tape file
vhs "$tape_file"

# Upload the generated GIF file
img-upload.sh "$gif_file"

rm $tape_file
