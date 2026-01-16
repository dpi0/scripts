#!/usr/bin/env bash

INCLUDE_DIRS=(
  "$HOME/Backup"
  "$HOME/Downloads"
  "$HOME/Pictures"
  "$HOME/projects"
  "$HOME/Screenshots"
  "$HOME/scripts"
  "$HOME/sh"
  "$HOME/Videos"
  "$HOME/Wallpapers"
  "$HOME/notes"
)

selection=$(
  fd . "${INCLUDE_DIRS[@]}" \
    --type f \
    --exclude .git \
    --hidden 2>/dev/null |
    sed "s|$HOME|~|" |
    rofi -sort -sorting-method fzf -disable-history -dmenu -no-custom -p "file: " |
    sed "s|~|$HOME|"
)

[ -z "$selection" ] && exit 1 # Exit if no selection

ext="${selection##*.}"
ext="${ext,,}"

case "$ext" in
jpg | jpeg | png | gif | bmp | webp)
  exec loupe "$selection"
  ;;
mp4 | mkv | webm | avi | mov | flv | mpg | mpeg | mp3 | flac | wav | ogg | opus | m4a | aac)
  exec mpv "$selection"
  ;;
pdf)
  exec evince "$selection"
  ;;
txt | py | rs | go | md | c | cpp | h | java | sh | ts | js | json | toml | yaml | yml | html | css | scss | lua | nix | zsh)
  exec kitty nvim "$selection"
  ;;
*)
  exec kitty nvim "$selection"
  ;;
esac
