#!/usr/bin/env bash

set -euo pipefail

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

APPIMAGE="${PKG}-${VERSION#v}-linux-x86-64.AppImage"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$APPIMAGE"
LOCAL_BIN_DIR="$HOME/bin"
LOCAL_SHARE_APPLICATIONS_DIR="$HOME/.local/share/applications"
APP_GENERIC_NAME="File Share"

mkdir -p "$LOCAL_BIN_DIR" "$LOCAL_SHARE_APPLICATIONS_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading $PKG $VERSION via $DOWNLOAD_URL..."
curl -fsLo "$TMP_DIR/$APPIMAGE" "$DOWNLOAD_URL"

echo "🚀 Installing to $LOCAL_BIN_DIR..."
cp "$TMP_DIR/$APPIMAGE" "$LOCAL_BIN_DIR"

setup_desktop_entry() {
	echo "⚙️ Setting up desktop entry for ${PKG} in ${LOCAL_SHARE_APPLICATIONS_DIR}..."
	tee -a ${LOCAL_SHARE_APPLICATIONS_DIR}/${PKG}.desktop <<EOF
[Desktop Entry]
Type=Application
Name=${PKG}
Exec=${LOCAL_BIN_DIR}/${APPIMAGE}
GenericName=${APP_GENERIC_NAME}
Terminal=false
EOF

	chmod +x $LOCAL_BIN_DIR/$APPIMAGE
	update-desktop-database "$LOCAL_SHARE_APPLICATIONS_DIR"
}

setup_desktop_entry

echo "✅ $PKG installation complete."
