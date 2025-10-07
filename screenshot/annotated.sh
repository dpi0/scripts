#!/usr/bin/env bash

# SCREENSHOT_DIR="$HOME/Screenshots"
# SCRIPT_PATH="$HOME/scripts"
# FILENAME="N_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

# mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1

# grim -g "$(slurp)" - | swappy -f - -o - > $SCREENSHOT_DIR/$FILENAME

# grim -g "$(slurp)" - | satty --filename - --fullscreen --output-filename $SCREENSHOT_DIR/$FILENAME

GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

timestamp="$(date +'%H-%M-%S')"
datestamp="$(date +'%d-%b-%y')"
window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
[ -z "$window_name" ] && window_name="NoWindow"
window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')

filename="$DIR/N $timestamp $datestamp - $window_name.png"
"$GRIMBLAST" --freeze save screen - | satty --filename - --fullscreen --output-filename "$filename"
[ -f "$filename" ] && dunstify -i "$filename" "Annotated Screenshot Saved" "$(basename "$filename")"
