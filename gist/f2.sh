#!/usr/bin/env bash

echo "███████╗██████╗ "
echo "██╔════╝╚════██╗"
echo "█████╗   █████╔╝"
echo "██╔══╝  ██╔═══╝ "
echo "██║     ███████╗"
echo "╚═╝     ╚══════╝"
echo "                "

PKG="f2"
REPO="ayoisaiah/f2"
echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ARCHIVE="${PKG}_${VERSION#v}_linux_amd64.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"

install_manually() {
  local TMP_DIR=$(mktemp -d)
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
  echo "🗑  Cleaning up..."
  rm -rf "$TMP_DIR"
}

if ! command -v $PKG &> /dev/null; then
  install_manually
  echo -e "\n✅ $PKG installed successfully at $(command -v $PKG)"
else
  echo "🟡 $PKG is already installed at $(command -v $PKG). Skipping installation."
  exit 0
fi

# Ensure LOCAL_BIN_DIR is in PATH
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
