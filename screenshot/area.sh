#!/usr/bin/env bash

GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

timestamp="$(date +'%H-%M-%S')"
datestamp="$(date +'%d-%b-%y')"

window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
[ -z "$window_name" ] && window_name="NoWindow"
window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_' | sed 's/__*/_/g')

filename="$DIR/A $timestamp $datestamp - $window_name.png"

export SLURP_ARGS="-d"

"$GRIMBLAST" --freeze copysave area "$filename"
[ -f "$filename" ] && dunstify -i "$filename" "Screenshot Saved" "$(basename "$filename")"
