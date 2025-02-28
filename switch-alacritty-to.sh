#!/usr/bin/env bash

THEME_FILE=~/.config/alacritty/alacritty.toml

if [ "$1" = "light" ]; then
  sed -i 's/ayu_dark/papercolor_light/' "$THEME_FILE"
elif [ "$1" = "dark" ]; then
  sed -i 's/papercolor_light/ayu_dark/' "$THEME_FILE"
else
  echo "Usage: $0 <light|dark>"
  exit 1
fi
