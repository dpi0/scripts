#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing neovim/neovim"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/neovim/neovim/releases/download/$VERSION/nvim-linux-x86_64.tar.gz" | tar -xz

echo "Installing..."
install -m755 "nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"

echo "Cleaning up..."
rm -rf "nvim-linux-x86_64"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: nvim --version"
