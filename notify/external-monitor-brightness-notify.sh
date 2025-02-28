#!/usr/bin/env bash

msgID="7211"
sleep 0.01  # Adjust the delay as needed
brightness_info=$(ddcutil --bus 9 getvcp 10)
brightness=$(echo "$brightness_info" | choose -f "," 0 | choose 8)
color=#FF00FFFF

dunstify "󰃞 $brightness%" -t 800 -r "$msgID" -h string:fgcolor:"$color" -h string:frcolor:"$color"
