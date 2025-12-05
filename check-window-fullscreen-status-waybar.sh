#!/usr/bin/env bash

fullscreen=$(hyprctl activewindow -j | jq -r .fullscreen)

if [[ "$fullscreen" == "1" ]]; then
	echo "   Fullscreen"
fi
