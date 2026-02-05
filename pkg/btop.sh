#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing aristocratos/btop"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/aristocratos/btop/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/aristocratos/btop/releases/download/$VERSION/btop-x86_64-linux-musl.tbz" | tar -xj

echo "Installing..."
install -m755 "btop/bin/btop" "$HOME/.local/bin/btop"

echo "Cleaning up..."
rm -rf btop

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: btop --version"
