#!/usr/bin/env bash

# LIGHT_WALLPAPER="$HOME/Wallpapers/desert4.jpg"
# DARK_WALLPAPER="$HOME/Wallpapers/MacOS Wallpapers/macOS-Wallpapers-master/Abstract 1.jpg"

# Ensure both wallpapers exist
[[ -f "$LIGHT_WALLPAPER" ]] || {
	echo "Error: Light wallpaper not found: $LIGHT_WALLPAPER" >&2
	exit 1
}
[[ -f "$DARK_WALLPAPER" ]] || {
	echo "Error: Dark wallpaper not found: $DARK_WALLPAPER" >&2
	exit 1
}

# Get current mode; fallback if unavailable
current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'unknown'")

# Determine new mode and wallpaper
if [[ $current_mode == "'prefer-dark'" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
	wallpaper="$LIGHT_WALLPAPER"
else
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	wallpaper="$DARK_WALLPAPER"
fi

# Restart swaybg with selected wallpaper
pkill -x swaybg 2>/dev/null
swaybg -m fill -i "$wallpaper" &
