#!/usr/bin/env bash

hex=$(hyprpicker --autocopy --no-fancy --format=hex)

# [possible values: rgb, rgb-float, rgb-r, rgb-g, rgb-b, hex, hsl, hsl-hue, hsl-saturation,
# hsl-lightness, hsv, hsv-hue, hsv-saturation, hsv-value, lch, lch-lightness, lch-chroma,
# lch-hue, oklch, oklch-lightness, oklch-chroma, oklch-hue, lab, lab-a, lab-b, oklab,
# oklab-l, oklab-a, oklab-b, luminance, brightness, ansi-8bit, ansi-24bit, ansi-8bit-value,
# ansi-8bit-escapecode, ansi-24bit-escapecode, cmyk, name]

if [ -n "$hex" ]; then
	hsl=$(pastel format hsl "$hex")
	rgb=$(pastel format rgb "$hex")
	oklch=$(pastel format oklch "$hex")

	fg="$(pastel textcolor "$hex" | pastel format hex)"

	notify-send \
		-h "string:fgcolor:$hex" \
		-h "string:frcolor:$hex" \
		-h "string:bgcolor:$fg" \
		"Color Picked" "Hex: $hex\nHSL: $hsl\nRGB: $rgb\nOKLCh: $oklch"
else
	notify-send "Color Picker" "No color selected"
fi
