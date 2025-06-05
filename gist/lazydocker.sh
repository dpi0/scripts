#!/usr/bin/env bash

set -euo pipefail

echo "██╗      █████╗ ███████╗██╗   ██╗██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ "
echo "██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗"
echo "██║     ███████║  ███╔╝  ╚████╔╝ ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝"
echo "██║     ██╔══██║ ███╔╝    ╚██╔╝  ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗"
echo "███████╗██║  ██║███████╗   ██║   ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║"
echo "╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
echo "                                                                                  "

PKG="lazydocker"
REPO="jesseduffield/lazydocker"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}_${VERSION#v}_Linux_x86_64.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="$HOME/.local/bin"

mkdir -p "$LOCAL_BIN_DIR"

ALIASES=(
  "alias lc='lazydocker'"
)

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
if ! install -m 755 "$TMP_DIR/$PKG" "$LOCAL_BIN_DIR/$PKG"; then
  echo "❌ Installation failed."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""
