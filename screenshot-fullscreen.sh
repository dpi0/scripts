#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
SCRIPT_PATH="$HOME/scripts"
FILENAME="F_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1
# "$SCRIPT_PATH" \
#   -m output \
#   -o "$SCREENSHOT_DIR" \
#   -f "$FILENAME"

grim "$SCREENSHOT_DIR/$FILENAME" && wl-copy < "$SCREENSHOT_DIR/$FILENAME" &&
  dunstify "✔️ Fullscreen screenshot taken." -i "$SCREENSHOT_DIR/$FILENAME"
