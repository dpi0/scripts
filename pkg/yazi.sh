#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing sxyazi/yazi"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/sxyazi/yazi/releases/download/$VERSION/yazi-x86_64-unknown-linux-musl.zip" -o yazi.zip
unzip -q yazi.zip

echo "Installing..."
install -m755 "yazi-x86_64-unknown-linux-musl/yazi" "$HOME/.local/bin/yazi"
install -m755 "yazi-x86_64-unknown-linux-musl/ya" "$HOME/.local/bin/ya"

echo "Cleaning up..."
rm -rf yazi.zip yazi-x86_64-unknown-linux-musl

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: yazi --version"
echo
echo "Run: ya --version"
