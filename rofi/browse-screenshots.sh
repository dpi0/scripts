#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
THEME="$HOME/.dotfiles/rofi/themes/image-grid-fullscreen.rasi"
OVERRIDE_COLS='listview { lines: 4; columns: 4; }'

chosen=$(
  find "$SCREENSHOT_DIR" -type f \
    \( -iname '*.png' -o -iname '*.jpg' \) \
    -print0 | sort -z |
    while IFS= read -r -d '' img; do
      filename=$(basename "$img")
      printf '%s\0icon\x1f%s\n' "$filename" "$img"
    done |
    rofi -dmenu -show-icons -i -p "Open screenshot" \
      -theme-str "$OVERRIDE_COLS" \
      -theme "$THEME"
)

[ -z "$chosen" ] && exit 0

fullpath=$(find "$SCREENSHOT_DIR" -type f -name "$chosen" | head -n1)

if [ -n "$fullpath" ]; then
  loupe "$fullpath"
else
  rofi -e "Error: Screenshot not found."
  exit 1
fi
