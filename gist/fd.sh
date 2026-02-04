#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing sharkdp/fd"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/sharkdp/fd/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/sharkdp/fd/releases/download/$VERSION/fd-$VERSION-x86_64-unknown-linux-musl.tar.gz" | tar -xz

echo "Installing..."
install -m755 "fd-$VERSION-x86_64-unknown-linux-musl/fd" "$HOME/.local/bin/fd"

echo "Cleaning up..."
rm -rf "fd-$VERSION-x86_64-unknown-linux-musl"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: fd --version"
