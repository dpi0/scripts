#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing eza-community/eza"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/eza-community/eza/releases/download/$VERSION/eza_x86_64-unknown-linux-musl.tar.gz" | tar -xz

echo "Installing..."
install -m755 eza "$HOME/.local/bin/eza"

echo "Cleaning up..."
rm -f eza

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: eza --version"
