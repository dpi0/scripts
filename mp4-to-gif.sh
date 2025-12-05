#!/usr/bin/env bash

# https://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

in="$1"
out="${2:-${in%.*}.gif}"
palette="$(mktemp --suffix=.png)"
fps=30
width=240
filters="fps=${fps},scale=${width}:-1:flags=lanczos"

ffmpeg -v warning -i "$in" \
  -vf "${filters},palettegen" \
  -frames:v 1 \
  -y "$palette"

ffmpeg -v warning -i "$in" -i "$palette" \
  -lavfi "${filters} [x]; [x][1:v] paletteuse" \
  -y "$out"

rm -f "$palette"
