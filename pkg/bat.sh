#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing sharkdp/bat"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/sharkdp/bat/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/sharkdp/bat/releases/download/$VERSION/bat-$VERSION-x86_64-unknown-linux-musl.tar.gz" | tar -xz

echo "Installing..."
install -m755 "bat-$VERSION-x86_64-unknown-linux-musl/bat" "$HOME/.local/bin/bat"

echo "Cleaning up..."
rm -rf "bat-$VERSION-x86_64-unknown-linux-musl"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: bat --version"
