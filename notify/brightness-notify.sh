#!/usr/bin/env bash

msgID=31232
brightness_info=$(brightnessctl -m)
brightness=$(echo "$brightness_info" | cut -d, -f4 | tr -d '%')
color="#FFBF00FF"

dunstify "󰃞 Brightness: $brightness%" \
  -t 700 \
  -r $msgID \
  -h int:value:"$brightness" \
  -h string:fgcolor:"$color" \
  -h string:frcolor:"$color" \
  -h string:hlcolor:"$color"
