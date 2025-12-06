#!/usr/bin/env bash

WALLPAPER_DIR="${1:-$HOME/Wallpapers}"
THEME="$HOME/.dotfiles/rofi/themes/image-grid-fullscreen.rasi"

if ! pgrep -x swww-daemon >/dev/null; then
	rofi -e "Error: swww-daemon not running."
	exit 1
fi

# build menu (filename + icon metadata) and show rofi
chosen=$(
	find "$WALLPAPER_DIR" -type f \
		\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
		-print0 | sort -z |
		while IFS= read -r -d '' img; do
			filename=$(basename "$img")
			printf '%s\0icon\x1f%s\n' "$filename" "$img"
		done | rofi -dmenu -show-icons -i -p "Choose wallpaper" -theme "$THEME"
)

[ -z "$chosen" ] && exit 0

fullpath=$(find "$WALLPAPER_DIR" -type f -name "$chosen" | head -n1)

if [ -n "$fullpath" ]; then
	swww img --transition-type random --transition-duration 1 "$fullpath"
else
	rofi -e "Error: Wallpaper file not found."
	exit 1
fi
