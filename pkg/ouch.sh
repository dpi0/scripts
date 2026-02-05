#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing ouch-org/ouch"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/ouch-org/ouch/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/ouch-org/ouch/releases/download/$VERSION/ouch-x86_64-unknown-linux-musl.tar.gz" | tar -xz

echo "Installing..."
install -m755 "ouch-x86_64-unknown-linux-musl/ouch" "$HOME/.local/bin/ouch"

echo "Cleaning up..."
rm -rf "ouch-x86_64-unknown-linux-musl"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: ouch --version"
