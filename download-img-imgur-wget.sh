#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

# Config
base_url=${IMGUR_URL}
page_url="$base_url/a/pquv6zd"
output_file="images.txt"

# Fetch page HTML and extract image paths
curl -s "$page_url" |
  grep -oP '<img[^>]+src="\K/[^"]+' |
  sed "s|^|$base_url|" |
  sort -u > "$output_file"

# Download all images using wget
wget -nc -i "$output_file"
