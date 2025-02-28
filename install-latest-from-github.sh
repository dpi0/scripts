#!/bin/bash

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <user/repo> <package-pattern>"
  echo "Example: $0 sharkdp/fd fd_VERSION_amd64.deb"
  exit 1
fi

USER_REPO="$1"
PACKAGE_PATTERN="$2"

# Get latest release version from GitHub API
VERSION=$(curl -s "https://api.github.com/repos/${USER_REPO}/releases/latest" | jq -r .tag_name)
PROCESSED_VERSION="${VERSION#v}"

# Generate package filename
PACKAGE_NAME="${PACKAGE_PATTERN//VERSION/$PROCESSED_VERSION}"

# Construct download URL
DOWNLOAD_URL="https://github.com/${USER_REPO}/releases/download/${VERSION}/${PACKAGE_NAME}"

# Download and install
wget -P "$HOME/Downloads" "$DOWNLOAD_URL"
sudo dpkg -i "$HOME/Downloads/${PACKAGE_NAME}"
