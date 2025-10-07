#!/usr/bin/env bash

# Get file selection via fd + rofi
selection=$(
  fd . "$HOME" \
    --type f \
    --hidden \
    --exclude node_modules \
    --exclude go/pkg/mod \
    --exclude .local/share \
    --exclude .local/state \
    --exclude .vscode \
    --exclude .config/Code \
    --exclude .Trash-1000 \
    --exclude .git \
    --exclude .cargo \
    --exclude .rustup \
    --exclude .cache \
    --exclude .mozilla \
    --exclude .npm \
    2> /dev/null |
    sed "s|$HOME|~|" |
    rofi -sort -sorting-method fzf -disable-history -dmenu -no-custom -p "file: " |
    sed "s|~|$HOME|"
)

[ -z "$selection" ] && exit 1 # Exit if no selection

# Get file extension (lowercased)
ext="${selection##*.}"
ext="${ext,,}"

case "$ext" in
  jpg | jpeg | png | gif | bmp | webp)
    exec loupe "$selection"
    ;;
  mp4 | mkv | webm | avi | mov | flv | mpg | mpeg | mp3 | flac | wav | ogg | opus | m4a | aac)
    exec mpv "$selection"
    ;;
  mp4 | mkv | webm | avi | mov | flv | mpg | mpeg)
    exec mpv "$selection"
    ;;
  pdf)
    exec evince "$selection"
    ;;
  txt | py | rs | go | md | c | cpp | h | java | sh | ts | js | json | toml | yaml | yml | html | css | scss | lua | nix | zsh)
    exec kitty nvim "$selection"
    ;;
  *)
    # xdg-open "$selection" &> /dev/null &
    exec kitty nvim "$selection"
    ;;
esac
