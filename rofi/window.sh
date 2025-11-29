#!/usr/bin/env bash

# rofi -show window

selected=$(
	hyprctl clients -j | jq -r '.[] | "\(.workspace.name)  \(.title)  \(.class)"' |
		rofi -dmenu -i -p "Windows"
)

ws=$(echo "$selected" | awk '{print $1}')

[ -n "$ws" ] && hyprctl dispatch workspace "$ws"
