#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing junegunn/fzf"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/junegunn/fzf/releases/download/$VERSION/fzf-${VERSION#v}-linux_amd64.tar.gz" | tar -xz

echo "Installing..."
install -m755 fzf "$HOME/.local/bin/fzf"

echo "Cleaning up..."
rm -f fzf

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: fzf --version"
