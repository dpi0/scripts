#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
SCRIPT_PATH="$HOME/scripts"
FILENAME="N_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

mkdir -p "$SCREENSHOT_DIR"

hyprpicker -r -z &
sleep 0.1

# grim -g "$(slurp)" - | swappy -f - -o - > $SCREENSHOT_DIR/$FILENAME

grim -g "$(slurp)" - | satty --filename - --fullscreen --output-filename $SCREENSHOT_DIR/$FILENAME
