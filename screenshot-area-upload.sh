#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
SCRIPT_PATH="$HOME/scripts"
FILENAME="UA_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

mkdir -p "$SCREENSHOT_DIR"

hyprpicker -r -z &
sleep 0.1
"$SCRIPT_PATH/hyprshot.sh" \
  -m region \
  -o "$SCREENSHOT_DIR" \
  -f "$FILENAME" -- "$SCRIPT_PATH/pst"
