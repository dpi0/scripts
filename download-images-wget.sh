#!/usr/bin/env bash

ENV_FILE="${PWD}/.env"

if [[ -f "$ENV_FILE" ]]; then
  export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | xargs -d '\n')
else
  echo "Error: Environment file not found at $ENV_FILE" >&2
  exit 1
fi


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
