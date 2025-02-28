#!/usr/bin/env bash

brightness_info=$(brightnessctl -m)
brightness=$(echo "$brightness_info" | cut -d, -f4 | tr -d '%')
color="#FFBF00FF" # RGBA format with quotes

dunstify "󰃞 Brightness: $brightness%" \
  -t 10000 \
  -r 31232 \
  -h int:value:"$brightness" \
  -h string:fgcolor:"$color" \
  -h string:frcolor:"$color" \
  -h string:hlcolor:"$color"
