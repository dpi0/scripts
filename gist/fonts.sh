#!/usr/bin/env bash

echo "███████╗ ██████╗ ███╗   ██╗████████╗███████╗"
echo "██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝"
echo "█████╗  ██║   ██║██╔██╗ ██║   ██║   ███████╗"
echo "██╔══╝  ██║   ██║██║╚██╗██║   ██║   ╚════██║"
echo "██║     ╚██████╔╝██║ ╚████║   ██║   ███████║"
echo "╚═╝      ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝"
echo "                                            "

LOCAL_SHARE_DIR="$HOME/.local/share"
FONTS_DIR="$HOME/.local/share/fonts"
MY_REPO="https://github.com/dpi0/fonts"

mkdir -p "$LOCAL_SHARE_DIR"

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

# Remove existing fonts directory (if any) and clone repo
rm -rf "$FONTS_DIR"
git clone --depth=1 "$MY_REPO" "$FONTS_DIR" &> /dev/null || {
  echo "❌ Git clone failed."
  exit 1
}

# Rebuild font cache
fc-cache -f "$FONTS_DIR"

echo "✅ Fonts setup complete and cache rebuilt."
