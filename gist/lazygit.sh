#!/usr/bin/env bash

set -euo pipefail

echo "██╗      █████╗ ███████╗██╗   ██╗ ██████╗ ██╗████████╗"
echo "██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██╔════╝ ██║╚══██╔══╝"
echo "██║     ███████║  ███╔╝  ╚████╔╝ ██║  ███╗██║   ██║   "
echo "██║     ██╔══██║ ███╔╝    ╚██╔╝  ██║   ██║██║   ██║   "
echo "███████╗██║  ██║███████╗   ██║   ╚██████╔╝██║   ██║   "
echo "╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝   ╚═╝   "
echo "                                                      "

PKG="lazygit"
REPO="jesseduffield/lazygit"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="${PKG}_${VERSION#v}_Linux_x86_64.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"
MY_REPO="https://github.com/dpi0/sh"

ALIASES=(
	"alias lz='lazygit'"
)

mkdir -p "$LOCAL_BIN_DIR" "$CONFIG_DIR/$PKG"

backup_pkg_config() {
	local config_file="$CONFIG_DIR/lazygit/config.yml"
	if [ -f "$config_file" ]; then
		local timestamp=$(date +"%d-%B-%Y_%H-%M-%S")
		mv "$config_file" "$config_file.$timestamp"
		echo "⏳️ Existing config backed up to $config_file.$timestamp"
	fi
}

deploy_pkg_config() {
	echo "📥 Downloading config to $CONFIG_DIR/lazygit/config.yml"
	curl -fsSL "${MY_REPO}/raw/main/lazygit/config.yml" -o "$CONFIG_DIR/lazygit/config.yml"
}

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
curl -fsSL --retry 3 --retry-delay 2 -o "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"

echo "📦 Extracting $ARCHIVE..."
if ! tar -xzf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"; then
	echo "❌ Extraction failed for $ARCHIVE"
	exit 1
fi

echo "🚀 Installing to $LOCAL_BIN_DIR..."
if ! install -m 755 "$TMP_DIR/$PKG" "$LOCAL_BIN_DIR/$PKG"; then
	echo "❌ Installation failed."
	exit 1
fi

backup_pkg_config
deploy_pkg_config

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""

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
