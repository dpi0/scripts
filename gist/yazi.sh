#!/usr/bin/env bash

echo "██╗   ██╗ █████╗ ███████╗██╗"
echo "╚██╗ ██╔╝██╔══██╗╚══███╔╝██║"
echo " ╚████╔╝ ███████║  ███╔╝ ██║"
echo "  ╚██╔╝  ██╔══██║ ███╔╝  ██║"
echo "   ██║   ██║  ██║███████╗██║"
echo "   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝"
echo "                            "

PKG="yazi"
REPO="sxyazi/yazi"
INSTALL_DIR_PATH="/usr/local/bin"
echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
ARCHIVE="${PKG}-x86_64-unknown-linux-musl.zip"
EXTRACTED_DIR="${ARCHIVE%.zip}"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ARCHIVE"
TMP_DIR=$(mktemp -d)
MY_REPO="https://github.com/dpi0/sh"
CONFIG_DIR="$HOME/.config"
PKG_CONFIG_DIR="$CONFIG_DIR/$PKG"
SHELL_DIR="$HOME/sh"
PKG_SHELL_DIR="$SHELL_DIR/$PKG"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
ALIASES=(
  "alias lf='yazi'"
)

# Ensure $INSTALL_DIR_PATH exists
mkdir -p "$CONFIG_DIR"

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
  if [ -d "$PKG_CONFIG_DIR" ]; then
    mv "$PKG_CONFIG_DIR" "$PKG_CONFIG_DIR.$TIMESTAMP.old"
    echo "⏳️ Existing config backed up to $PKG_CONFIG_DIR.$TIMESTAMP.old"
  fi
}

install_manually() {
  echo "📥 Downloading $PKG $VERSION in $TMP_DIR via $DOWNLOAD_URL..."
  if ! curl -fsLo "$TMP_DIR/$ARCHIVE" "$DOWNLOAD_URL"; then
    echo "🟥 Error: Failed to download $PKG from $DOWNLOAD_URL" >&2
    exit 1
  fi

  echo "📦 Extracting $ARCHIVE to $TMP_DIR..."
  if ! unzip -q "$TMP_DIR/$ARCHIVE" -d "$TMP_DIR"; then
    echo "🟥 Error: Failed to extract $ARCHIVE" >&2
    rm -rf "$TMP_DIR"
    exit 1
  fi

  echo "🚀 Installing to $INSTALL_DIR_PATH..."

  # when inside double quotes "", {ya, yazi} won't expand.
  echo "🟨 Need superuser password to copy $TMP_DIR/yazi-x86_64-unknown-linux-musl/ya and $TMP_DIR/yazi-x86_64-unknown-linux-musl/yazi to $INSTALL_DIR_PATH"
  sudo cp "$TMP_DIR/yazi-x86_64-unknown-linux-musl/ya" "$TMP_DIR/yazi-x86_64-unknown-linux-musl/yazi" "$INSTALL_DIR_PATH"

  echo "🗑  Cleaning up..."
  rm -rf "$TMP_DIR"
}

install_pkg() {
  if command -v apt &> /dev/null || command -v unzip &> /dev/null; then
    echo "🟨 Need superuser password to install unzip using APT package manager..."
    sudo apt install -y unzip && install_manually
  elif command -v pacman &> /dev/null; then
    echo "🟨 Need superuser password to install yazi using Pacman package manager..."
    echo "🔹  sudo pacman -S --noconfirm yazi"
    sudo pacman -S --noconfirm yazi
  elif command -v dnf &> /dev/null; then
    echo "🟨 Need superuser password to install unzip using DNF package manager..."
    sudo dnf install -y unzip && install_manually
  else
    echo "🟥 Unsupported system. Installing manually..." && install_manually
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

if ! command -v $PKG &> /dev/null; then
  echo "🟤 $PKG not found. Installing..."
  install_pkg
  echo -e "\n✅ $PKG installed successfully!"
else
  echo "🟡 $PKG is already installed at $(command -v $PKG). Skipping installation."
  exit 0
fi

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""
