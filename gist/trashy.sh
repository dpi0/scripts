#!/usr/bin/env bash

set -euo pipefail

echo "████████╗██████╗  █████╗ ███████╗██╗  ██╗██╗   ██╗"
echo "╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝"
echo "   ██║   ██████╔╝███████║███████╗███████║ ╚████╔╝ "
echo "   ██║   ██╔══██╗██╔══██║╚════██║██╔══██║  ╚██╔╝  "
echo "   ██║   ██║  ██║██║  ██║███████║██║  ██║   ██║   "
echo "   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝   "
echo "                                                  "

PKG="trash"
REPO="oberblastmeister/trashy"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}-x86_64-unknown-linux-gnu.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="/usr/local/bin"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
curl -fsSL --retry 3 --retry-delay 2 -o "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"

echo "📦 Extracting $ARCHIVE..."
if ! tar -xzf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"; then
  echo "❌ Extraction failed for $ARCHIVE"
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "🚀 Installing to $LOCAL_BIN_DIR..."
echo "🟨 Need superuser password to install $PKG to $LOCAL_BIN_DIR/$PKG"
if ! sudo install -m 755 "$TMP_DIR/$PKG" "$LOCAL_BIN_DIR/$PKG"; then
  echo "❌ Installation failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo -e "\n🔹 To setup alias run:"
echo "     printf \"alias rm='echo \\\"This is a dangerous command. Use trash instead.\\\"'\\n\" >> \"\$HOME/.\$(basename \$SHELL)rc\""
echo ""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""
