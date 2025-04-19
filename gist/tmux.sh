#!/usr/bin/env bash

echo "████████╗███╗   ███╗██╗   ██╗██╗  ██╗";
echo "╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝";
echo "   ██║   ██╔████╔██║██║   ██║ ╚███╔╝ ";
echo "   ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗ ";
echo "   ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗";
echo "   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝";
echo "                                     ";

PKG="tmux"
CONFIG_FILE="$HOME/.tmux.conf"
MY_REPO="https://github.com/dpi0/sh"
CONFIG_URL="${MY_REPO}/raw/main/.tmux.conf"
ALIASES=(
"alias t='tmux'"
"alias ta='tmux a -t'"
"alias tls='tmux ls'"
"alias tn='tmux new-session -s'"
"alias tk='tmux kill-session -t'"
"alias tka='tmux kill-server'"
)

mkdir -p "$HOME/.tmux/plugins"

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

# Stop running tmux server if active
stop_tmux_server() {
    if tmux info &> /dev/null; then
        echo "Stopping running $PKG server..."
        tmux kill-server
    else
        echo "No running $PKG server detected. Skipping kill-server."
    fi
}

stop_tmux_server

if ! command -v $PKG &> /dev/null; then
  if command -v apt &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using APT package manager..."
    echo "🔹  sudo apt install -y $PKG"
  elif command -v pacman &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using Pacman package manager..."
    echo "🔹  sudo pacman -S --noconfirm $PKG"
    sudo pacman -S --noconfirm $PKG
  elif command -v dnf &> /dev/null; then
    echo "🟨 Need superuser password to install $PKG using DNF package manager..."
    echo "🔹  sudo dnf install -y $PKG"
    sudo dnf install -y $PKG
  else
    echo "🟥 Unsupported system. Installing manually..." && install_manually
  fi
  echo -e "\n✅ $PKG installed successfully at $(command -v $PKG)"
else
  echo "🟡 $PKG is already installed at $(command -v $PKG). Skipping installation."
  exit 0
fi

# Backup existing config 
if [ -f "$CONFIG_FILE" ]; then
  local timestamp=$(date +"%d-%B-%Y_%H-%M-%S")
  mv "$CONFIG_FILE" "$CONFIG_FILE.$timestamp.old"
  echo "⏳️ Existing config backed up to $CONFIG_FILE.$timestamp.old"
fi

# Download  config
curl -fsSL "$CONFIG_URL" -o "$CONFIG_FILE"

git clone "https://github.com/MunifTanjim/tmux-suspend" "$HOME/.tmux/plugins/tmux-suspend"
git clone "https://github.com/tmux-plugins/tmux-continuum" "$HOME/.tmux/plugins/tmux-continuum"
git clone "https://github.com/tmux-plugins/tmux-resurrect" "$HOME/.tmux/plugins/tmux-resurrect"
git clone "https://github.com/wfxr/tmux-fzf-url" "$HOME/.tmux/plugins/tmux-fzf-url"
git clone "https://github.com/omerxx/tmux-sessionx" "$HOME/.tmux/plugins/tmux-sessionx"
git clone "https://github.com/omerxx/tmux-floax" "$HOME/.tmux/plugins/tmux-floax"

echo -e "\n🔹 To setup alias run:"
echo -n "    printf \"%s\n\" "
printf "\"%s\" " "${ALIASES[@]}"
echo ">> \"\$HOME/.\$(basename \$SHELL)rc\""
echo "🔹 Then apply changes with:"
echo "    source \"\$HOME/.\$(basename \$SHELL)rc\""
