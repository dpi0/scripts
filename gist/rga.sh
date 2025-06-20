#!/usr/bin/env bash

set -euo pipefail

echo "██████╗ ██╗██████╗  ██████╗ ██████╗ ███████╗██████╗      █████╗ ██╗     ██╗     "
echo "██╔══██╗██║██╔══██╗██╔════╝ ██╔══██╗██╔════╝██╔══██╗    ██╔══██╗██║     ██║     "
echo "██████╔╝██║██████╔╝██║  ███╗██████╔╝█████╗  ██████╔╝    ███████║██║     ██║     "
echo "██╔══██╗██║██╔═══╝ ██║   ██║██╔══██╗██╔══╝  ██╔═══╝     ██╔══██║██║     ██║     "
echo "██║  ██║██║██║     ╚██████╔╝██║  ██║███████╗██║         ██║  ██║███████╗███████╗"
echo "╚═╝  ╚═╝╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝         ╚═╝  ╚═╝╚══════╝╚══════╝"
echo "                                                                                "

PKG="ripgrep-all"
REPO="phiresky/ripgrep-all"

echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

ARCHIVE="ripgrep_all-${VERSION}-x86_64-unknown-linux-musl.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="$HOME/.local/bin"

mkdir -p "$LOCAL_BIN_DIR"

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
# NOTE: rga-fzf needs to be in the same directory as rga and rga-fzf-open
for bin in rga rga-fzf rga-fzf-open; do
	if ! install -m 755 "$TMP_DIR/${ARCHIVE%.tar.gz}/$bin" "$LOCAL_BIN_DIR/$bin"; then
		echo "❌ Installation of $bin failed."
		exit 1
	fi
done

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
