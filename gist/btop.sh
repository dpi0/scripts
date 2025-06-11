#!/usr/bin/env bash

set -euo pipefail

echo "██████╗ ████████╗ ██████╗ ██████╗ "
echo "██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗"
echo "██████╔╝   ██║   ██║   ██║██████╔╝"
echo "██╔══██╗   ██║   ██║   ██║██╔═══╝ "
echo "██████╔╝   ██║   ╚██████╔╝██║     "
echo "╚═════╝    ╚═╝    ╚═════╝ ╚═╝     "
echo "                                  "

PKG="btop"
REPO="aristocratos/btop"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}-x86_64-linux-musl.tbz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="$HOME/.local/bin"

CONFIG_DIR="$HOME/.config"
MY_REPO="https://github.com/dpi0/sh"
SHELL_DIR="$HOME/sh"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")

mkdir -p "$LOCAL_BIN_DIR" "$CONFIG_DIR/$PKG"

backup_pkg_config() {
	if [ -f "$CONFIG_DIR/$PKG/btop.conf" ]; then
		mv "$CONFIG_DIR/$PKG/btop.conf" "$CONFIG_DIR/$PKG/btop.conf.$TIMESTAMP"
		echo "⏳️ Existing config backed up to $CONFIG_DIR/$PKG/btop.conf.$TIMESTAMP"
	fi
}

deploy_pkg_config() {
	echo "📥 Downloading config $MY_REPO/raw/main/btop/btop.conf to $CONFIG_DIR/$PKG/btop.conf"
	curl -fsSL "${MY_REPO}/raw/main/btop/btop.conf" -o "$CONFIG_DIR/$PKG/btop.conf"
}

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
curl -fsSL --retry 3 --retry-delay 2 -o "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"

echo "📦 Extracting $ARCHIVE..."
if ! tar -xjf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"; then
	echo "❌ Extraction failed for $ARCHIVE"
	echo "ℹ️ Perhaps you don't have 'bzip2' installed which is needed to extract this $ARCHIVE archive."
	exit 1
fi

echo "🚀 Installing to $LOCAL_BIN_DIR..."
if ! install -m 755 "$TMP_DIR/$PKG/bin/$PKG" "$LOCAL_BIN_DIR/$PKG"; then
	echo "❌ Installation failed."
	exit 1
fi

# backup_pkg_config
# deploy_pkg_config

case ":$PATH:" in
*":$LOCAL_BIN_DIR:"*) ;;
*)
	echo -e "\n⚠️ In order to run $PKG, Add $LOCAL_BIN_DIR to your PATH:"
	echo "   export PATH=\"$LOCAL_BIN_DIR:\$PATH\""
	echo "🟡 This is temporary and will not persist after you exit this shell session."
	echo -e "\nℹ️ To permanently add $LOCAL_BIN_DIR to your PATH, follow the instructions for your shell:"
	echo "🔹 Bash (Linux/macOS):   echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
	echo "🔹 Zsh (macOS/Linux):    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
	echo "🔹 Fish shell:           echo 'set -Ux fish_user_paths \$HOME/.local/bin \$fish_user_paths' >> ~/.config/fish/config.fish"
	echo "🔹 General (if unsure):  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.profile && source ~/.profile"
	echo -e "\n⏩ After this, restart your terminal or run 'exec \$SHELL' to apply changes."
	;;
esac
