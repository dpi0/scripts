#!/usr/bin/env bash

fullscreen=$(hyprctl activewindow -j | jq -r .fullscreen)
# fullscreen=$(hyprctl activewindow | grep -q "fullscreen: 1")

if [[ "$fullscreen" == "1" ]]; then
	echo "   Fullscreen"
fi
