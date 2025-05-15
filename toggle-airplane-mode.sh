#!/usr/bin/env bash

STATE_FILE="$HOME/.local/state/airplane_mode_state"

if [ ! -f "$STATE_FILE" ]; then
	echo "off" >"$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "off" ]; then
	echo "on" >"$STATE_FILE"
	notify-send "🟢 Airplane Mode Enabled"
else
	echo "off" >"$STATE_FILE"
	notify-send "🔴 Airplane Mode Disabled"
fi
