#!/usr/bin/env bash
set -eo pipefail

echo ">> Installing jesseduffield/lazygit"

mkdir -p "$HOME/.local/bin"

VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
[ -n "$VERSION" ] || { echo "Failed to get version"; exit 1; }

echo "Downloading and extracting..."
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/$VERSION/lazygit_${VERSION#v}_Linux_x86_64.tar.gz" | tar -xz

echo "Installing..."
install -m755 lazygit "$HOME/.local/bin/lazygit"

echo "Cleaning up..."
rm -f lazygit

echo
echo "Done! Make sure $HOME/.local/bin is in your PATH."
echo
echo "Run: lazygit --version"
