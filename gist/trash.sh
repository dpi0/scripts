#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing oberblastmeister/trashy"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/oberblastmeister/trashy/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/oberblastmeister/trashy/releases/download/$VERSION/trash-x86_64-unknown-linux-gnu.tar.gz" | tar -xz

echo "Installing..."
install -m755 "trash" "$HOME/.local/bin/trash"

echo "Cleaning up..."
rm -f "trash"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: trash --version"
