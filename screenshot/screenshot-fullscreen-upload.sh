#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
SCRIPT_PATH="$HOME/scripts"
FILENAME="UF_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1
# "$SCRIPT_PATH/hyprshot.sh" \
#   -m output \
#   -o "$SCREENSHOT_DIR" \
#   -f "$FILENAME" -- "$SCRIPT_PATH/pst"

grim "$SCREENSHOT_DIR/$FILENAME" &&
  "$SCRIPT_PATH/pst" "$SCREENSHOT_DIR/$FILENAME" &&
  echo -n "$SCREENSHOT_DIR/$FILENAME" | wl-copy &&
  dunstify "✔️ Fullscreen screenshot taken." -i "$SCREENSHOT_DIR/$FILENAME"
