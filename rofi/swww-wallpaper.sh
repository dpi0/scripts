#!/usr/bin/env bash

# Configuration
readonly WALLPAPER_DIR="${1:-$HOME/Wallpapers}"
readonly ICON_SIZE="${ICON_SIZE:-450}"
readonly COLUMNS=5
readonly ROWS=3

# Check if swww-daemon is running
check_daemon() {
	if ! pgrep -x swww-daemon >/dev/null; then
		rofi -e "Error: swww-daemon not running."
		exit 1
	fi
}

get_wallpapers() {
	find "$WALLPAPER_DIR" -type f \
		\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
		-print0 | sort -z |
		while IFS= read -r -d '' img; do
			local filename
			filename=$(basename "$img")
			printf '%s\0icon\x1f%s\n' "$filename" "$img"
		done
}

show_menu() {
	rofi -dmenu -show-icons -i -p "Choose wallpaper" \
		-theme-str "
            listview {
                columns: ${COLUMNS};
                lines: ${ROWS};
                layout: vertical;
								fixed-columns: true;
								fixed-lines: true;
            }
            element {
                orientation: vertical;
            }
            element-icon {
                size: ${ICON_SIZE}px;
                horizontal-align: 0.5;
            }
            element-text {
                horizontal-align: 0.5;
                vertical-align: 0.5;
            }
        "
}

# Set wallpaper
set_wallpaper() {
	local filename="$1"
	local fullpath
	fullpath=$(find "$WALLPAPER_DIR" -type f -name "$filename" | head -n1)

	if [ -n "$fullpath" ]; then
		swww img --transition-type random --transition-duration 1 "$fullpath"
	else
		rofi -e "Error: Wallpaper file not found."
		exit 1
	fi
}

main() {
	check_daemon

	local chosen
	chosen=$(get_wallpapers | show_menu)

	[ -z "$chosen" ] && exit 0

	set_wallpaper "$chosen"
}

main
