#!/usr/bin/env bash

echo "██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗███████╗███╗   ██╗██████╗ "
echo "██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝██╔════╝████╗  ██║██╔══██╗"
echo "██║     ██║   ██║██║     ███████║██║     ███████╗█████╗  ██╔██╗ ██║██║  ██║"
echo "██║     ██║   ██║██║     ██╔══██║██║     ╚════██║██╔══╝  ██║╚██╗██║██║  ██║"
echo "███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████║███████╗██║ ╚████║██████╔╝"
echo "╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═════╝ "
echo "                                                                           "

PKG="LocalSend"
REPO="localsend/localsend"
echo "🔍 Fetching latest version..."
json=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")
VERSION=$(echo "$json" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
APP="${PKG}-${VERSION#v}-linux-x86-64.AppImage"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$APP"
APPLICATIONS_DIR="$HOME/Applications"
LOCAL_SHARE_APPLICATIONS_DIR="$HOME/.local/share/applications"
INSTALL_PATH="$APPLICATIONS_DIR"
APP_GENERIC_NAME="File Share"

mkdir -p "$APPLICATIONS_DIR" "$LOCAL_SHARE_APPLICATIONS_DIR"

install_manually() {
  local tmp_dir
  tmp_dir=$(mktemp -d)
  curl -fsLo "$tmp_dir/$APP" "$DOWNLOAD_URL"
  cp "$tmp_dir/$APP" "$INSTALL_PATH"
  rm -rf "$tmp_dir"
}

setup_desktop_entry() {
  echo "⚙️ Setting up desktop entry for ${PKG} in ${LOCAL_SHARE_APPLICATIONS_DIR}..."
  tee -a ${LOCAL_SHARE_APPLICATIONS_DIR}/${PKG}.desktop << EOF
[Desktop Entry]
Type=Application
Name=${PKG}
Exec=${APPLICATIONS_DIR}/${APP}
GenericName=${APP_GENERIC_NAME}
Terminal=false
EOF

  chmod +x $APPLICATIONS_DIR/$APP
  update-desktop-database "$LOCAL_SHARE_APPLICATIONS_DIR"
}

install_pkg() {
  echo "🚀 Installing manually to $INSTALL_PATH..." && install_manually
}

if ls $HOME/Applications/LocalSend* &> /dev/null; then
  echo "🟫 $PKG not found. Installing..."
  install_pkg
else
  echo "🟨 $PKG is already installed."
fi

setup_desktop_entry

echo "✅ $PKG installation complete."
