#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
SCRIPT_PATH="$HOME/scripts"
FILENAME="UN_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

mkdir -p "$SCREENSHOT_DIR"

hyprpicker -r -z &
sleep 0.1

grim -g "$(slurp)" -t ppm - | satty --filename - --fullscreen --output-filename "$SCREENSHOT_DIR/$FILENAME" &&
  "$SCRIPT_PATH/pst" "$SCREENSHOT_DIR/$FILENAME" &&
  echo -n "$SCREENSHOT_DIR/$FILENAME" | wl-copy &&
  dunstify "✔️ Annotated screenshot saved & uploaded." -i "$SCREENSHOT_DIR/$FILENAME"
