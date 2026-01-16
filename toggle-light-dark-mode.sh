#!/usr/bin/env bash

# Get current mode; fallback if unavailable
current_mode=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'unknown'")

# Determine new mode and wallpaper
if [[ $current_mode == "'prefer-dark'" ]]; then
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
	dunstify -u normal -i preferences-desktop-theme \
		"󰖨   Currently in Light Mode"
else
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	dunstify -u normal -i preferences-desktop-theme \
		"󰖔   Currently in Dark Mode"
fi
