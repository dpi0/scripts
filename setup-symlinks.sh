#!/usr/bin/env bash

set -e # Exit on error

DOTFILES="$HOME/.dotfiles"
CONFIG="$HOME/.config"

# Ensure required directories exist
mkdir -p "$CONFIG"

# Function to create or replace symlink
link() {
  [ -L "$2" ] && [ "$(readlink -- "$2")" = "$1" ] && return
  # rm -rf "$2"
  trash "$2"
  ln -s "$1" "$2"
  echo "🔗 Linked: $2 -> $1"
}

# Symlink dotfiles
link "$DOTFILES/.zprofile" "$HOME/.zprofile"
link "$DOTFILES/alacritty" "$CONFIG/"
link "$DOTFILES/dunst" "$CONFIG/"
link "$DOTFILES/foot" "$CONFIG/"
link "$DOTFILES/gammastep" "$CONFIG/"
link "$DOTFILES/hypr" "$CONFIG/"
link "$DOTFILES/keyd" "$CONFIG/"
link "$DOTFILES/rofi" "$CONFIG/"
# link "$DOTFILES/swappy" "$CONFIG/"
link "$DOTFILES/systemd" "$CONFIG/"
link "$DOTFILES/vscode/Code/User/" "$CONFIG/Code/"
link "$DOTFILES/vscode/argv.json" "$HOME/.vscode/argv.json"
link "$DOTFILES/waybar" "$CONFIG/"

echo "🎉 All dotfiles are linked!"
