#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing schollz/croc"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/schollz/croc/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/schollz/croc/releases/download/$VERSION/croc_${VERSION}_Linux-64bit.tar.gz" | tar -xz

echo "Installing..."
install -m755 croc "$HOME/.local/bin/croc"

echo "Cleaning up..."
rm -f croc

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: croc --version"
