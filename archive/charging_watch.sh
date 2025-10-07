#!/usr/bin/env bash

STATUS_FILE="/sys/class/power_supply/BAT0/status"
LAST_STATE=$(<"$STATUS_FILE")

while true; do
	CURRENT_STATE=$(<"$STATUS_FILE")
	if [[ "$LAST_STATE" != "Charging" && "$CURRENT_STATE" == "Charging" ]]; then
		notify-send -u normal -h string:fgcolor:#00FF00 -h string:frcolor:#00FF00 "🔌 Charger Connected" "Battery is now: $CURRENT_STATE"
	elif [[ "$LAST_STATE" == "Charging" && "$CURRENT_STATE" != "Charging" ]]; then
		notify-send -u critical -h string:fgcolor:#FFA500 -h string:frcolor:#FFA500 "⚠️ Charger Disconnected" "Battery is now: $CURRENT_STATE"
	fi
	LAST_STATE="$CURRENT_STATE"
	sleep 1
done
