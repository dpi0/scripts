#!/usr/bin/env bash

echo "██████╗ ████████╗ ██████╗ ██████╗ "
echo "██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗"
echo "██████╔╝   ██║   ██║   ██║██████╔╝"
echo "██╔══██╗   ██║   ██║   ██║██╔═══╝ "
echo "██████╔╝   ██║   ╚██████╔╝██║     "
echo "╚═════╝    ╚═╝    ╚═════╝ ╚═╝     "
echo "                                  "

PKG="btop"
REPO="aristocratos/btop"
ARCHIVE="${PKG}-x86_64-linux-musl.tbz"
echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"
MY_REPO="https://github.com/dpi0/sh"
PKG_CONFIG_DIR="$CONFIG_DIR/$PKG"
SHELL_DIR="$HOME/sh"
PKG_SHELL_DIR="$SHELL_DIR/$PKG"
mkdir -p "$LOCAL_BIN_DIR" "$PKG_CONFIG_DIR"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")

install_dependencies() {
  command -v git &> /dev/null && echo -e "✅ git already installed. Skipping installation.\n" && return 0
  echo "📥 Installing git..."
  for c in apt pacman dnf; do
    if command -v $c &> /dev/null; then
      cmd="sudo $c $([ $c = pacman ] && echo -S --noconfirm --needed || echo install -y) git"
      echo "🟨 Running: $cmd"
      eval $cmd && echo "🎉 Installed!" && return 0
    fi
  done
  echo "🟥 Unsupported package manager"
  return 1
}

install_dependencies

backup_pkg_config() {
  if [ -f "$PKG_CONFIG_DIR/btop.conf" ]; then
    mv "$PKG_CONFIG_DIR/btop.conf" "$PKG_CONFIG_DIR/btop.conf.old.$TIMESTAMP"
    echo "⏳️ Existing config backed up to $PKG_CONFIG_DIR/btop.conf.old.$TIMESTAMP"
  fi
}

deploy_pkg_config() {
  echo "📥 Downloading config $MY_REPO/raw/main/btop.conf to $PKG_CONFIG_DIR/btop.conf"
  curl -fsSL "${MY_REPO}/raw/main/btop/btop.conf" -o "$PKG_CONFIG_DIR/btop.conf"
}

install_manually() {
  local TMP_DIR=$(mktemp -d)
  echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
  curl -fsSL --retry 3 --retry-delay 2 -o "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"
  echo "📦 Extracting $ARCHIVE..."
  if ! tar -xjf "$TMP_DIR/$ARCHIVE" -C "$TMP_DIR"; then
    echo "❌ Extraction failed for $ARCHIVE"
    exit 1
  fi
  echo "🚀 Installing to $LOCAL_BIN_DIR..."
  if ! install -m 755 "$TMP_DIR/$PKG/bin/$PKG" "$LOCAL_BIN_DIR/$PKG"; then
    echo "❌ Installation failed."
    exit 1
  fi
  echo "🗑  Cleaning up..."
  rm -rf "$TMP_DIR"
}

backup_pkg_config
deploy_pkg_config

if ! command -v $PKG &> /dev/null; then
  if command -v apt &> /dev/null || command -v bzip2 &> /dev/null; then
    echo "🟨 Need superuser password to install bzip2 using APT package manager..."
    echo "🔹  sudo apt install -y bzip2"
    sudo apt install -y bzip2 && install_manually
  elif command -v pacman &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using Pacman package manager..."
    echo "🔹  sudo pacman -S --noconfirm $PKG"
    sudo pacman -S --noconfirm $PKG
  elif command -v dnf &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using DNF package manager..."
    echo "🔹  sudo dnf install -y $PKG"
    sudo dnf install -y $PKG
  else
    echo "🟥 Unsupported system. Installing manually..." && install_manually
  fi
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
