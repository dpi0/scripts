#!/usr/bin/env bash

INCLUDE_DIRS=(
  "$HOME/Backup"
  "$HOME/bin"
  "$HOME/Books"
  "$HOME/Downloads"
  "$HOME/Pictures"
  "$HOME/projects"
  "$HOME/Screenshots"
  "$HOME/scripts"
  "$HOME/sh"
  "$HOME/temp"
  "$HOME/Videos"
  "$HOME/Wallpapers"
  "$HOME/.dotfiles"
)

selection=$(
  fd . "${INCLUDE_DIRS[@]}" \
    --type f \
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

# EXCLUDE LIST
# selection=$(
#   fd . "$HOME" \
#     --type f \
#     --hidden \
#     --exclude node_modules \
#     --exclude go/pkg/mod \
#     --exclude .local/share \
#     --exclude .local/state \
#     --exclude .vscode \
#     --exclude .config/Code \
#     --exclude .Trash-1000 \
#     --exclude .git \
#     --exclude .cargo \
#     --exclude .rustup \
#     --exclude .cache \
#     --exclude .mozilla \
#     --exclude .npm \
#     --exclude .bun \
#     --exclude .terrascan \
#     --exclude .bundle \
#     --exclude .gradle \
#     --exclude .pub-cache \
#     --exclude .config/libreoffice/ \
#     --exclude .flutter-devtools \
#     --exclude .claude \
#     --exclude .dart-tool \
#     --exclude .dotnet \
#     --exclude .opencode \
#     --exclude Android \
#     --exclude .kube \
#     --exclude .keychain \
#     --exclude .dartServer \
#     --exclude .java \
#     --exclude .password-store \
#     --exclude .android \
#     --exclude .gemini \
#     --exclude .vagrant.d \
#     --exclude .config \
#     --exclude .zen \
#     --exclude .tmux \
#     --exclude .ansible \
#     --exclude .docker \
#     --exclude .gnupg \
#     --exclude .logseq \
#     2>/dev/null |
#     sed "s|$HOME|~|" |
#     rofi -sort -sorting-method fzf -disable-history -dmenu -no-custom -p "file: " |
#     sed "s|~|$HOME|"
# )
