#!/usr/bin/env bash

swayidle -w \
	timeout 5 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && brightnessctl -s && brightnessctl set 5%' \
	resume 'brightnessctl -r' \
	timeout 10 'hyprlock' \
	timeout 15 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && hyprctl dispatch dpms off' \
	resume 'hyprctl dispatch dpms on' \
	timeout 1200 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && systemctl suspend' \
	after-resume 'hyprctl dispatch dpms on'
