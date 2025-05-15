#!/usr/bin/env bash

echo "██╗   ██╗██╗███╗   ███╗"
echo "██║   ██║██║████╗ ████║"
echo "██║   ██║██║██╔████╔██║"
echo "╚██╗ ██╔╝██║██║╚██╔╝██║"
echo " ╚████╔╝ ██║██║ ╚═╝ ██║"
echo "  ╚═══╝  ╚═╝╚═╝     ╚═╝"
echo "                       "

PKG="vim"
CONFIG_FILE="$HOME/.vimrc"
MY_REPO="https://github.com/dpi0/sh"
CONFIG_URL="${MY_REPO}/raw/main/vim/.vimrc"

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

# Backup existing config
if [ -f "$CONFIG_FILE" ]; then
  local timestamp=$(date +"%d-%B-%Y_%H-%M-%S")
  mv "$CONFIG_FILE" "$CONFIG_FILE.$timestamp.old"
  echo "⏳️ Existing config backed up to $CONFIG_FILE.$timestamp.old"
fi

# Download latest config
curl -fsSL "$CONFIG_URL" -o "$CONFIG_FILE"

if ! command -v $PKG &> /dev/null; then
  if command -v apt &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using APT package manager..."
    echo "🔹  sudo apt install -y $PKG"
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
