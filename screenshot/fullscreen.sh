#!/usr/bin/env bash

# SCREENSHOT_DIR="$HOME/Screenshots"
# SCRIPT_PATH="$HOME/scripts"
# FILENAME="F_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

# mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1
# "$SCRIPT_PATH" \
#   -m output \
#   -o "$SCREENSHOT_DIR" \
#   -f "$FILENAME"

# grim "$SCREENSHOT_DIR/$FILENAME" && wl-copy < "$SCREENSHOT_DIR/$FILENAME" &&
#   dunstify "✔️ Fullscreen screenshot taken." -i "$SCREENSHOT_DIR/$FILENAME"

GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

timestamp="$(date +'%H-%M-%S')"
datestamp="$(date +'%d-%b-%y')"
window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
[ -z "$window_name" ] && window_name="NoWindow"
window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')

filename="$DIR/F $timestamp $datestamp - $window_name.png"
"$GRIMBLAST" --freeze copysave screen "$filename"
[ -f "$filename" ] && dunstify -i "$filename" "Screenshot Saved" "$(basename "$filename")"
