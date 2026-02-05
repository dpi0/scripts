#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing FiloSottile/age"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/FiloSottile/age/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/FiloSottile/age/releases/download/$VERSION/age-$VERSION-linux-amd64.tar.gz" | tar -xz

echo "Installing..."
install -m755 "age/age" "$HOME/.local/bin/age"
install -m755 "age/age-keygen" "$HOME/.local/bin/age-keygen"

echo "Cleaning up..."
rm -rf age

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: age --version"
