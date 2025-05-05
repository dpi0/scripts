#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

# Config
base_url="${IMGUR_APP_URL}"
page_url="$base_url/a/pquv6zd"
output_file="images.txt"

# Fetch page HTML and extract image paths
curl -s "$page_url" |
  grep -oP '<img[^>]+src="\K/[^"]+' |
  sed "s|^|$base_url|" |
  sort -u > "$output_file"

# Download all images using wget
wget -nc -i "$output_file"
