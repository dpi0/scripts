#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing jesseduffield/lazydocker"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/$VERSION/lazydocker_${VERSION#v}_Linux_x86_64.tar.gz" | tar -xz

echo "Installing..."
install -m755 lazydocker "$HOME/.local/bin/lazydocker"

echo "Cleaning up..."
rm -f lazydocker

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: lazydocker --version"
