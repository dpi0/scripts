#!/usr/bin/env bash

shutdown=" Shutdown"
reboot="󰜉 Reboot"
logout="󰍃 Logout"
suspend="󰤄 Suspend"
hibernate="󰋊 Hibernate"
lock="󰍁 Lock"
reboot_to_windows="󰨡 Reboot to Windows"

options="$shutdown\n$reboot\n$logout\n$suspend\n$hibernate\n$lock\n$reboot_to_windows"

chosen=$(echo -e "$options" | rofi -no-config -dmenu -i -theme ~/.dotfiles/rofi/themes/minimal-fullscreen.rasi -theme-str '* { font: "JetBrainsMono NF 20"; }')

case "$chosen" in
"$shutdown")
	systemctl poweroff
	;;
"$reboot")
	systemctl reboot
	;;
"$logout")
	hyprctl dispatch exit
	;;
"$suspend")
	systemctl suspend
	;;
"$hibernate")
	systemctl hibernate
	;;
"$reboot_to_windows")
	pkexec /usr/bin/efibootmgr --bootnext 0001 && /usr/bin/reboot
	;;
"$lock")
	hyprlock
	;;
esac
