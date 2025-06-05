#!/usr/bin/env bash

set -euo pipefail

echo "███████╗ ██████╗ ███╗   ██╗████████╗███████╗"
echo "██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝"
echo "█████╗  ██║   ██║██╔██╗ ██║   ██║   ███████╗"
echo "██╔══╝  ██║   ██║██║╚██╗██║   ██║   ╚════██║"
echo "██║     ╚██████╔╝██║ ╚████║   ██║   ███████║"
echo "╚═╝      ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝"
echo "                                            "

LOCAL_SHARE_DIR="$HOME/.local/share"
FONTS_DIR="$HOME/.local/share/fonts"
MY_REPO="https://github.com/dpi0/fonts"

if ! command -v git &> /dev/null; then
  echo "🟥 'git' is not installed. Please install it manually. Exiting..."
  exit 1
fi
echo "✅ git is present."

mkdir -p "$LOCAL_SHARE_DIR"

# Remove existing fonts directory (if any) and clone repo
rm -rf "$FONTS_DIR"
echo "📥 Cloning $MY_REPO to $FONTS_DIR..."
git clone --depth=1 "$MY_REPO" "$FONTS_DIR" &> /dev/null || {
  echo "❌ Git clone failed."
  exit 1
}

# Rebuild font cache
fc-cache -f "$FONTS_DIR"

echo "✅ Fonts setup complete and cache rebuilt."
