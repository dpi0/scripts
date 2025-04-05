#!/usr/bin/env bash

HOME_DIR="${HOME:-$(eval echo ~$(whoami))}"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
MY_REPO="https://github.com/dpi0/sh"

for file in .gitattributes .gitconfig; do
    if [[ -f "$HOME_DIR/$file" ]]; then
        mv "$HOME_DIR/$file" "$HOME_DIR/${file}.bak.$TIMESTAMP"
        echo "Backup created: $HOME_DIR/${file}.bak.$TIMESTAMP"
    fi
done

curl -fsSL "${MY_REPO}/raw/main/git/.gitattributes" -o "$HOME_DIR/.gitattributes" || { echo "❌ Failed to download .gitattributes"; exit 1; }
curl -fsSL "${MY_REPO}/raw/main/git/.gitconfig" -o "$HOME_DIR/.gitconfig" || { echo "❌ Failed to download .gitconfig"; exit 1; }

# Validate Git config
git config --list > /dev/null || { echo "❌ Invalid .gitconfig detected"; exit 1; }

echo "git config has been setup successfully! 🎉"