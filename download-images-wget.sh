#!/usr/bin/env bash

# Config
base_url="https://imgur.dpi0.cloud"
page_url="$base_url/a/pquv6zd"
output_file="images.txt"

# Fetch page HTML and extract image paths
curl -s "$page_url" |
  grep -oP '<img[^>]+src="\K/[^"]+' |
  sed "s|^|$base_url|" |
  sort -u > "$output_file"

# Download all images using wget
wget -nc -i "$output_file"
