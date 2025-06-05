#!/usr/bin/env bash

set -euo pipefail

echo " ██████╗ ██╗████████╗"
echo "██╔════╝ ██║╚══██╔══╝"
echo "██║  ███╗██║   ██║   "
echo "██║   ██║██║   ██║   "
echo "╚██████╔╝██║   ██║   "
echo " ╚═════╝ ╚═╝   ╚═╝   "
echo "                     "

HOME_DIR="${HOME:-$(eval echo ~$(whoami))}"
GIT_CONFIG_DIR="$HOME_DIR/.config/git"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
MY_REPO="https://github.com/dpi0/sh"

mkdir -p "$GIT_CONFIG_DIR"

if ! command -v git &> /dev/null; then
  echo "🟥 'git' is not installed. Please install it manually. Exiting..."
  exit 1
fi
echo "✅ git is present."

if [[ -f "$HOME_DIR/.gitconfig" ]]; then
  echo "📦 Found existing git .gitconfig. Backing up..."
  mv "$HOME_DIR/.gitconfig" "$HOME_DIR/.gitconfig.bak.$TIMESTAMP"
  echo "✅ Backup created: $HOME_DIR/.gitconfig.bak.$TIMESTAMP"
else
  echo "🟡 No existing git config found."
fi

if [[ -f "$GIT_CONFIG_DIR/config" ]]; then
  echo "📦 Found existing git config. Backing up..."
  mv "$GIT_CONFIG_DIR/config" "$GIT_CONFIG_DIR/config.bak.$TIMESTAMP"
  echo "✅ Backup created: $GIT_CONFIG_DIR/config.bak.$TIMESTAMP"
else
  echo "🟡 No existing git config found."
fi

echo "📥 Downloading git config..."
curl -fsSL "${MY_REPO}/raw/main/git/.gitconfig" -o "$GIT_CONFIG_DIR/config" || {
  echo "❌ Failed to download .gitconfig"
  exit 1
}

echo "🔹 Validating config..."
git config --global --list &> /dev/null || {
  echo "❌ Invalid .gitconfig"
  exit 1
}
