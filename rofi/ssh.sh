#!/usr/bin/env bash

host=$(grep -E '^Host ' ~/.ssh/config | awk '{print $2}' | grep -v '[*?]' |
	rofi -dmenu -p "SSH" -kb-custom-1 "Alt+Return" -mesg "Alt+Enter: New kitty window")
ret=$?

if [ -n "$host" ]; then
	case $ret in
	0) # Enter → tmux new-window
		tmux new-window "ssh $host"
		hyprctl dispatch workspace 2
		;;
	10) # Alt+Enter → new kitty window
		kitty ssh "$host" &
		;;
	esac
fi
