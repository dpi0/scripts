#!/usr/bin/env bash

swayidle -w \
timeout 300 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && brightnessctl -s && brightnessctl set 5%' \
resume 'brightnessctl -r' \
timeout 480 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && hyprctl dispatch dpms off' \
resume 'hyprctl dispatch dpms on' \
timeout 900 'swaylock -feF' \
timeout 1200 '[ "$(cat /sys/class/power_supply/AC/online)" = "0" ] && systemctl suspend' \
after-resume 'hyprctl dispatch dpms on'
