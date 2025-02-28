#!/usr/bin/env bash

msgID="9312"
battery=$(< /sys/class/power_supply/BAT0/capacity)
charging_status=$(< /sys/class/power_supply/BAT0/status)
color="#C059FF"

if [[ "$charging_status" == "Charging" ]]; then
  icon=""
  message="$battery% (Charging)"
else
  icon="󰂁"
  message="$battery%"
fi

dunstify "$icon $message" -t 2500 -r "$msgID" -h string:fgcolor:"$color" -h string:frcolor:"$color"
