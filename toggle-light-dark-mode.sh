#!/usr/bin/env bash

light_wallpaper="$HOME/Wallpapers/desert4.jpg"
dark_wallpaper="$HOME/Wallpapers/MacOS Wallpapers/macOS-Wallpapers-master/Abstract 1.jpg"

# Ensure both wallpapers exist
[[ -f "$light_wallpaper" ]] || {
  echo "Error: Light wallpaper not found: $light_wallpaper" >&2
  exit 1
}
[[ -f "$dark_wallpaper" ]] || {
  echo "Error: Dark wallpaper not found: $dark_wallpaper" >&2
  exit 1
}

# Get current mode; fallback if unavailable
current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null || echo "'unknown'")

# Determine new mode and wallpaper
if [[ $current_mode == "'prefer-dark'" ]]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  wallpaper="$light_wallpaper"
else
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  wallpaper="$dark_wallpaper"
fi

# Restart swaybg with selected wallpaper
pkill -x swaybg 2> /dev/null
swaybg -m fill -i "$wallpaper" &
