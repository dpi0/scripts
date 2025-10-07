#!/usr/bin/env bash

WALLPAPER_DIR="${1:-$HOME/Wallpapers}"
ICON_SIZE="${ICON_SIZE:-200}"

if ! pgrep -x swww-daemon >/dev/null; then
	rofi -e "Error: swww-daemon not running."
	exit 1
fi

chosen=$(
	find "$WALLPAPER_DIR" -type f \
		\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
		-print0 | sort -z |
		while IFS= read -r -d '' img; do
			printf '%s\0icon\x1f%s\n' "$img" "$img"
		done |
		rofi -dmenu -show-icons -i -p "Choose wallpaper" \
			-theme-str "element-icon { size: ${ICON_SIZE}px; }"
)

[ -z "${chosen:-}" ] && exit 0
swww img "$chosen"
