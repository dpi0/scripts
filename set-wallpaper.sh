#!/usr/bin/env bash

# Get current color scheme
color_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null || echo "'unknown'")

# Choose wallpaper based on color scheme
case "$color_scheme" in
  "'prefer-dark'")
    wallpaper="$DARK_WALLPAPER"
    ;;
  "'prefer-light'")
    wallpaper="$LIGHT_WALLPAPER"
    ;;
  *)
    # Default to light if unknown
    wallpaper="$LIGHT_WALLPAPER"
    ;;
esac

# Apply wallpaper
pkill -x swaybg 2> /dev/null
swaybg -m fill -i "$wallpaper" &
