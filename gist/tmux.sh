#!/usr/bin/env bash

set -euo pipefail

echo "████████╗███╗   ███╗██╗   ██╗██╗  ██╗"
echo "╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝"
echo "   ██║   ██╔████╔██║██║   ██║ ╚███╔╝ "
echo "   ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗ "
echo "   ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗"
echo "   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝"
echo "                                     "

PKG="tmux"

MY_REPO="https://github.com/dpi0/sh"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$HOME/.tmux.conf"
SHELL_DIR="$HOME/sh"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")

ALIASES=(
  "alias t='tmux'"
  "alias ta='tmux a -t'"
  "alias tls='tmux ls'"
  "alias tn='tmux new-session -s'"
  "alias tk='tmux kill-session -t'"
  "alias tka='tmux kill-server'"
)

if ! command -v $PKG &> /dev/null; then
  echo "🟥 'Tmux' is not installed. Please install it manually. Exiting..."
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "🟥 'git' is not installed. Please install it manually. Exiting..."
  exit 1
fi
echo "✅ git is present."

# Stop running tmux server if active
stop_tmux_server() {
  if tmux info &> /dev/null; then
    echo "Stopping running $PKG server..."
    tmux kill-server
  else
    echo "No running $PKG server detected. Skipping kill-server."
  fi
}

backup_pkg_config() {
  if [ -f "$CONFIG_FILE" ]; then
    TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
    mv "$CONFIG_FILE" "$CONFIG_FILE.$TIMESTAMP"
    echo "⏳️ Existing config backed up to $CONFIG_FILE.$TIMESTAMP"
  fi
}

deploy_pkg_config() {
  echo "📥 Cloning $MY_REPO to $SHELL_DIR"
  [ -d "$SHELL_DIR" ] && rm -rf "$SHELL_DIR"
  git clone --depth 1 "${MY_REPO}.git" "$SHELL_DIR" &> /dev/null

  echo "🔗 Symlinking $SHELL_DIR/tmux/tmux.conf to $HOME/.tmux.conf"
  ln -s "$SHELL_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
}

backup_pkg_config
deploy_pkg_config
stop_tmux_server

# Install TPM
echo "📥 Downloading TPM (TMUX Plugin Manager) to $HOME/.tmux/plugins/tpm"
git clone --depth=1 "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" > /dev/null 2>&1

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""

echo -e "ℹ️ To install the list of plugins present in $SHELL_DIR/tmux/plugins.conf, hit 'prefix + ALT+i' to install. where my current prefix is 'ALT+n'"
