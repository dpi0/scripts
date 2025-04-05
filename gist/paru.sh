#!/usr/bin/env bash

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

VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
ARCHIVE="${PKG}-${VERSION}-x86_64.tar.zst"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"

if ! command -v $PKG &> /dev/null; then
  TMP_DIR=$(mktemp -d)
  echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
  curl -fsLo "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"
  echo "📦 Extracting $ARCHIVE..."
  tar -I zstd -xf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"
  echo "🚀 Installing $PKG..."
  echo "🟨 Need superuser password to install $PKG..."
  sudo install -m 755 "$TMP_DIR/$PKG" "/usr/local/bin/$PKG"
  echo "🗑  Cleaning up..."
  rm -rf "$TMP_DIR"
  echo -e "\n✅ $PKG installed successfully!"
else
  echo "🟡 $PKG is already installed. Skipping installation."
  exit 0
fi
