#!/usr/bin/env bash

# SCREENSHOT_DIR="$HOME/Screenshots"
# SCRIPT_PATH="$HOME/scripts"
# FILENAME="UA_($(date +'%H-%M-%S'))_($(date +'%d-%b-%y')).png"

# mkdir -p "$SCREENSHOT_DIR"

# hyprpicker -r -z &
# sleep 0.1
# "$SCRIPT_PATH/hyprshot.sh" \
#   -m region \
#   -o "$SCREENSHOT_DIR" \
#   -f "$FILENAME" -- "$SCRIPT_PATH/pst"

GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
UPLOADSCRIPT="$HOME/scripts/bin-upload.sh"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

timestamp="$(date +'%H-%M-%S')"
datestamp="$(date +'%d-%b-%y')"
window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
[ -z "$window_name" ] && window_name="NoWindow"
window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')

filename="$DIR/UA $timestamp $datestamp - $window_name.png"
"$GRIMBLAST" --freeze save area "$filename"
if [ -f "$filename" ]; then
  url=$("$UPLOADSCRIPT" "$filename")
  echo -n "$url" | wl-copy
  dunstify -i "$filename" "Screenshot Uploaded" "$url"
fi
