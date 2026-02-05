#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing rclone/rclone"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/rclone/rclone/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL -o rclone.zip "https://github.com/rclone/rclone/releases/download/$VERSION/rclone-${VERSION}-linux-amd64.zip"
unzip -q rclone.zip

echo "Installing..."
install -m755 "rclone-${VERSION}-linux-amd64/rclone" "$HOME/.local/bin/rclone"

echo "Cleaning up..."
rm -rf rclone.zip "rclone-${VERSION}-linux-amd64"

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: rclone --version"
