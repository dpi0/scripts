#!/usr/bin/env bash

set -e # Exit on error

DOTFILES="$HOME/.dotfiles"
CONFIG="$HOME/.config"
SHELL_DIR="$HOME/shell"

# Ensure required directories exist
mkdir -p "$HOME/.local/bin" "$CONFIG/btop" "$CONFIG/yazi"

# Function to create or replace symlink
link() {
  [ -L "$2" ] && [ "$(readlink -- "$2")" = "$1" ] && return
  # rm -rf "$2"
  trash "$2"
  ln -s "$1" "$2"
  echo "🔗 Linked: $2 -> $1"
}

# Symlink dotfiles
link "$DOTFILES/dunst" "$CONFIG/"
link "$DOTFILES/gammastep" "$CONFIG/"
link "$DOTFILES/hypr" "$CONFIG/"
link "$DOTFILES/lazygit" "$CONFIG/"
link "$DOTFILES/mpv" "$CONFIG/"
link "$DOTFILES/rofi" "$CONFIG/"
link "$DOTFILES/foot" "$CONFIG/"
link "$DOTFILES/waybar" "$CONFIG/"
link "$DOTFILES/systemd" "$CONFIG/"
link "$DOTFILES/vscode/Code/User/" "$CONFIG/Code/"

link "$DOTFILES/vscode/argv.json" "$HOME/.vscode/argv.json"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES/git/.gitattributes" "$HOME/.gitattributes"

link "$SHELL_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$SHELL_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$SHELL_DIR/yazi" "$CONFIG/yazi"
link "$SHELL_DIR/.zprofile" "$HOME/.zprofile"
link "$SHELL_DIR/.vimrc" "$HOME/.vimrc"
link "$SHELL_DIR/btop.conf" "$CONFIG/btop/btop.conf"

echo "🎉 All dotfiles are linked!"

# ln -s $DOTFILES/alacritty $CONFIG/
# ln -s $DOTFILES/fusuma $CONFIG/
# ln -s $DOTFILES/kitty $CONFIG/
# ln -s $DOTFILES/qrcp $CONFIG/
# ln -s $DOTFILES/qalculate $CONFIG/
# ln -s $DOTFILES/flameshot $CONFIG/
# ln -s $DOTFILES/sway/swaync $CONFIG/
# ln -s $DOTFILES/sway/swaylock $CONFIG/
# ln -s $DOTFILES/firefox/chrome/ $HOME/more/dpi0-firefox-profile/
# ln -s $DOTFILES/firefox/user.js $HOME/more/dpi0-firefox-profile/

# scripts
#install-from-latest-github.sh -o charmbracelet -r freeze -a freeze_0.1.6_Linux_x86_64.tar.gz -d $HOME/test -rae -rde; cp $HOME/test/freeze_0.1.6_Linux_x86_64.tar/freeze $HOME/Applications
