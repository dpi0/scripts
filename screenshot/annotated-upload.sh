#!/usr/bin/env bash

# SCREENSHOT_DIR="$HOME/Screenshots"
# SCRIPT_PATH="$HOME/scripts"
# FILENAME="UN_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

# mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1

# grim -g "$(slurp)" -t ppm - | satty --filename - --fullscreen --output-filename "$SCREENSHOT_DIR/$FILENAME" &&
#   "$SCRIPT_PATH/pst" "$SCREENSHOT_DIR/$FILENAME" &&
#   echo -n "$SCREENSHOT_DIR/$FILENAME" | wl-copy &&
#   dunstify "✔️ Annotated screenshot saved & uploaded." -i "$SCREENSHOT_DIR/$FILENAME"

GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
UPLOADSCRIPT="$HOME/scripts/bin-upload.sh"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

timestamp="$(date +'%H-%M-%S')"
datestamp="$(date +'%d-%b-%y')"

# Get active window title
window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
[ -z "$window_name" ] && window_name="NoWindow"
window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')

filename="$DIR/NU $timestamp $datestamp - $window_name.png"

# Take fullscreen shot -> annotate -> save
"$GRIMBLAST" --freeze save screen - | satty --filename - --fullscreen --output-filename "$filename"

# Upload if saved
if [ -f "$filename" ]; then
  url=$("$UPLOADSCRIPT" "$filename")
  echo -n "$url" | wl-copy
  dunstify -i "$filename" "Annotated Screenshot Uploaded" "$url"
fi
