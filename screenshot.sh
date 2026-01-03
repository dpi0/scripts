#!/usr/bin/env bash

DIR="$HOME/Screenshots"

# Check if grimblast is available in PATH
if ! command -v grimblast >/dev/null 2>&1; then
  dunstify -u critical "Grimblast not found." "Install grimblast or add it to PATH."
  exit 1
fi

make_filename() {
  local prefix="$1"
  local timestamp datestamp window_name
  timestamp="$(date +'%H-%M-%S')"
  datestamp="$(date +'%d-%b-%y')"
  window_name="$(hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty')"
  [ -z "$window_name" ] && window_name="NoWindow"
  window_name="$(printf '%s' "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')"
  printf '%s/%s %s %s - %s.png\n' "$DIR" "$prefix" "$timestamp" "$datestamp" "$window_name"
}

notify_image_saved() {
  local file="$1"
  [ ! -f "$file" ] && return 0

  local base action
  base="$(basename "$file")"

  if command -v dunstify >/dev/null 2>&1; then
    action=$(dunstify \
      -i "$file" \
      -A "open,Open Screenshot" \
      "Screenshot Saved" \
      "$base")

    if [ "$action" = "open" ]; then
      if command -v loupe >/dev/null 2>&1; then
        loupe "$file" &
      elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$file" &
      fi
    fi
  else
    notify-send -i "$file" "Screenshot Saved" "$base"
  fi
}

screenshot_area() {
  local file
  file="$(make_filename "A")"
  export SLURP_ARGS="-d"
  grimblast --freeze copysave area "$file"
  notify_image_saved "$file"
}

screenshot_fullscreen() {
  local file
  file="$(make_filename "F")"
  grimblast --freeze copysave screen "$file"
  notify_image_saved "$file"
}

screenshot_annotated() {
  local file
  file="$(make_filename "N")"
  grimblast --freeze save screen - |
    satty --filename - --fullscreen --output-filename "$file"
  notify_image_saved "$file"
}

screenshot_window() {
  local file
  file="$(make_filename "W")"
  grimblast --freeze copysave active "$file"
  notify_image_saved "$file"
}

usage() {
  echo "Usage: $0 {area|fullscreen|annotated|window}" >&2
  exit 1
}

mode="$1"
case "$mode" in
area) screenshot_area ;;
fullscreen) screenshot_fullscreen ;;
annotated) screenshot_annotated ;;
window) screenshot_window ;;
*) usage ;;
esac
