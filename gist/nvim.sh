#!/usr/bin/env bash

set -euo pipefail

echo "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
echo "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║"
echo "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║"
echo "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║"
echo "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║"
echo "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝"
echo "                                                  "

PKG="nvim"
REPO="neovim/neovim"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}-linux-x86_64.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"

INSTALL_DIR="/opt"
MY_REPO="https://github.com/dpi0/nvim"
CONFIG_DIR="$HOME/.config"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")

ALIASES=(
	"alias v='nvim'"
	"alias vim="nvim""
	"alias svim='sudo -E nvim'"
)

if ! command -v git &>/dev/null; then
	echo "🟥 'git' is not installed. Please install it manually. Exiting..."
	exit 1
fi
echo "✅ git is present."

mkdir -p "$CONFIG_DIR"

backup_pkg_config() {
	if [ -d "$CONFIG_DIR/$PKG" ]; then
		mv "$CONFIG_DIR/$PKG" "$CONFIG_DIR/$PKG.$TIMESTAMP"
		echo "⏳️ Existing config backed up to $CONFIG_DIR/$PKG.$TIMESTAMP"
	fi
}

deploy_pkg_config() {
	echo "📥 Cloning $MY_REPO to $CONFIG_DIR"
	git clone --depth 1 "${MY_REPO}.git" "$CONFIG_DIR" &>/dev/null

	# echo "🔗 Symlinking $CONFIG_DIR/$PKG to $CONFIG_DIR/$PKG"
	# ln -s "$CONFIG_DIR/$PKG" "$CONFIG_DIR/$PKG"
}

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

echo "🚀 Installing to $INSTALL_DIR..."
echo "🟨 Need superuser password to copy $TMP_DIR/nvim-linux-x86_64 to $INSTALL_DIR"
echo "🟨 and symlink binary /opt/nvim-linux-x86_64/bin/nvim to /usr/local/bin/nvim"
sudo cp -r "$TMP_DIR/${ARCHIVE%.tar.gz}" "$INSTALL_DIR"
sudo ln -sf "/opt/nvim-linux-x86_64/bin/nvim" "/usr/local/bin/nvim"

backup_pkg_config
deploy_pkg_config

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""

echo -e "\n ℹ️ To uninstall all neovim config and start from scratch run:"
echo "    rm -rf $HOME/.config/nvim $HOME/.local/share/nvim $HOME/.local/state/nvim"
