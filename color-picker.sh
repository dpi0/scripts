#!/usr/bin/env bash

color=$(hyprpicker --autocopy --no-fancy --format=hex)

if [ -n "$color" ]; then
	notify-send \
		-h "string:fgcolor:$color" \
		-h "string:frcolor:$color" \
		"Color: $color"
else
	notify-send "Color Picker" "No color selected"
fi
