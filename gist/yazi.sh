#!/usr/bin/env bash

set -euo pipefail

echo "██╗   ██╗ █████╗ ███████╗██╗"
echo "╚██╗ ██╔╝██╔══██╗╚══███╔╝██║"
echo " ╚████╔╝ ███████║  ███╔╝ ██║"
echo "  ╚██╔╝  ██╔══██║ ███╔╝  ██║"
echo "   ██║   ██║  ██║███████╗██║"
echo "   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝"
echo "                            "

PKG="yazi"
REPO="sxyazi/yazi"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}-x86_64-unknown-linux-musl.zip"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"

MY_REPO="https://github.com/dpi0/sh"
CONFIG_DIR="$HOME/.config"
SHELL_DIR="$HOME/sh"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
LOCAL_BIN_DIR="/usr/local/bin"

ALIASES=(
  "alias lf='yazi'"
)

mkdir -p "$CONFIG_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v git &> /dev/null; then
  echo "🟥 'git' is not installed. Please install it manually. Exiting..."
  exit 1
fi
echo "✅ git is present."

echo "📥 Downloading $PKG $VERSION in $TMP_DIR via $DOWNLOAD_URL..."
if ! curl -fsLo "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"; then
  echo "🟥 Error: Failed to download $PKG from $DOWNLOAD_URL" >&2
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "📦 Extracting $ARCHIVE to $TMP_DIR..."
if ! unzip -q "$TMP_DIR/$ARCHIVE" -d "$TMP_DIR"; then
  echo "🟥 Error: Failed to extract $ARCHIVE" >&2
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "🚀 Installing to $LOCAL_BIN_DIR..."
# when inside double quotes "", {ya, yazi} won't expand.
echo "🟨 Need superuser password to copy $TMP_DIR/yazi-x86_64-unknown-linux-musl/ya and $TMP_DIR/yazi-x86_64-unknown-linux-musl/yazi to $LOCAL_BIN_DIR"
echo "🔹This will run : sudo cp '$TMP_DIR/yazi-x86_64-unknown-linux-musl/ya' '$TMP_DIR/yazi-x86_64-unknown-linux-musl/yazi' '$LOCAL_BIN_DIR'"
sudo cp "$TMP_DIR/yazi-x86_64-unknown-linux-musl/ya" "$TMP_DIR/yazi-x86_64-unknown-linux-musl/yazi" "$LOCAL_BIN_DIR"

backup_pkg_config() {
  if [ -d "$PKG_CONFIG_DIR" ]; then
    mv "$PKG_CONFIG_DIR" "$PKG_CONFIG_DIR.$TIMESTAMP.old"
    echo "⏳️ Existing config backed up to $PKG_CONFIG_DIR.$TIMESTAMP.old"
  fi
}

deploy_pkg_config() {
  echo "📥 Cloning $MY_REPO to $SHELL_DIR"
  [ -d "$SHELL_DIR" ] && rm -rf "$SHELL_DIR"
  git clone --depth 1 "${MY_REPO}.git" "$SHELL_DIR" &> /dev/null
  echo "🔗 Symlinking $PKG_SHELL_DIR to $PKG_CONFIG_DIR"
  ln -s "$PKG_SHELL_DIR" "$PKG_CONFIG_DIR"
}

backup_pkg_config
deploy_pkg_config

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""
