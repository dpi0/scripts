#!/usr/bin/env bash

SCREENSHOT_DIR="$HOME/Screenshots"
THEME="$HOME/.dotfiles/rofi/themes/image-grid-fullscreen.rasi"
OVERRIDE_COLS='listview { lines: 4; columns: 4; }'

chosen=$(
  fd -t f -e png -e jpg . "$SCREENSHOT_DIR" \
    --print0 |
    xargs -0 stat --format '%Y %n' |
    sort -rn |
    cut -d' ' -f2- |
    while IFS= read -r img; do
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
  mime=$(file --mime-type -b "$fullpath")
  wl-copy --type "$mime" <"$fullpath"
  notify-send "Screenshot copied" "$chosen"
  loupe "$fullpath"
else
  rofi -e "Error: Screenshot not found."
  exit 1
fi
