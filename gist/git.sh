#!/usr/bin/env bash

echo " ██████╗ ██╗████████╗";
echo "██╔════╝ ██║╚══██╔══╝";
echo "██║  ███╗██║   ██║   ";
echo "██║   ██║██║   ██║   ";
echo "╚██████╔╝██║   ██║   ";
echo " ╚═════╝ ╚═╝   ╚═╝   ";
echo "                     ";

HOME_DIR="${HOME:-$(eval echo ~$(whoami))}"
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
MY_REPO="https://github.com/dpi0/sh"

install_dependencies() {
  command -v git &> /dev/null && echo -e "✅ git already installed. Skipping installation.\n" && return 0
  echo "📥 Installing git..."
  for c in apt pacman dnf; do
    if command -v $c &> /dev/null; then
      cmd="sudo $c $([ $c = pacman ] && echo -S --noconfirm --needed || echo install -y) git"
      echo "🟨 Running: $cmd"
      eval $cmd && echo "🎉 Installed!" && return 0
    fi
  done
  echo "🟥 Unsupported package manager"
  return 1
}

install_dependencies

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
