#!/usr/bin/env bash

echo " █████╗  ██████╗  ██████╗ "
echo "██╔══██╗██╔════╝ ██╔════╝ "
echo "███████║██║  ███╗██║  ███╗"
echo "██╔══██║██║   ██║██║   ██║"
echo "██║  ██║╚██████╔╝╚██████╔╝"
echo "╚═╝  ╚═╝ ╚═════╝  ╚═════╝ "
echo "                          "

PKG="agg"
REPO="asciinema/agg"
echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ARCHIVE="${PKG}-x86_64-unknown-linux-musl"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"

install_manually() {
  echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
  curl -fsLo "$LOCAL_BIN_DIR/$ARCHIVE" "$DOWNLOAD_URL"
  echo "🚀 Installing..."
  chmod +x "$LOCAL_BIN_DIR/$ARCHIVE"
  mv "$LOCAL_BIN_DIR/$ARCHIVE" "$LOCAL_BIN_DIR/$PKG"
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
