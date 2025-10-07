#!/usr/bin/env bash

brightnessctl "$@" > /dev/null

msgID=31232
color="#FFBF00FF"
brightnow="$(brightnessctl g)"
brightmax="$(brightnessctl m)"
brightness=$(awk "BEGIN {printf \"%d\", ${brightnow}/${brightmax}*100}")

dunstify -a "changeBrightness" \
  "󰃞 Brightness: ${brightness}%" \
  -u low \
  -t 700 \
  -r "$msgID" \
  -h int:value:"$brightness" \
  -h string:fgcolor:"$color" \
  -h string:frcolor:"$color" \
  -h string:hlcolor:"$color"
