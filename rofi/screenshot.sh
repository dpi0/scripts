#!/usr/bin/env bash

SCREENSHOT_SCRIPT="$HOME/scripts/screenshot.sh"

declare -A actions=(
  ["Area - Region"]="$SCREENSHOT_SCRIPT area"
  ["Fullscreen"]="$SCREENSHOT_SCRIPT fullscreen"
  ["Annotated - Satty"]="$SCREENSHOT_SCRIPT annotated"
  ["Window - Current window under cursor"]="$SCREENSHOT_SCRIPT window"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -dmenu -i)

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
  eval "${actions[$chosen]}"
fi
