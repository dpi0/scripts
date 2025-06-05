#!/usr/bin/env bash

set -euo pipefail

echo "██████╗  █████╗ ██████╗ ██╗   ██╗"
echo "██╔══██╗██╔══██╗██╔══██╗██║   ██║"
echo "██████╔╝███████║██████╔╝██║   ██║"
echo "██╔═══╝ ██╔══██║██╔══██╗██║   ██║"
echo "██║     ██║  ██║██║  ██║╚██████╔╝"
echo "╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ "
echo "                                 "

PKG="paru"
REPO="Morganamilo/paru"

echo "🟨 Need superuser password to install dependencies using Pacman package manager..."
echo "🔹  sudo pacman -S --noconfirm base-devel zstd git jq"
sudo pacman -S --noconfirm base-devel zstd git jq

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}-${VERSION}-x86_64.tar.zst"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
curl -fsLo "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"

echo "📦 Extracting $ARCHIVE..."
tar -I zstd -xf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"

echo "🚀 Installing $PKG..."
echo "🟨 Need superuser password to install $PKG..."
sudo install -m 755 "$TMP_DIR/$PKG" "/usr/local/bin/$PKG"
