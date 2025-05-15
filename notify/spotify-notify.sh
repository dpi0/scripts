#!/usr/bin/env bash

msgID="9823"
previous_metadata=""
spot_status=""

while true; do
  current_metadata=$(playerctl metadata --format "{{artist}} {{title}} {{album}}")
  current_status=$(playerctl status)

  if [ "$current_status" != "$spot_status" ] || [ "$current_metadata" != "$previous_metadata" ]; then
    if [ "$current_status" = "Playing" ]; then
      dunstify "Now Playing" "$current_metadata" -t 5000 -r "$msgID" -u "normal"
    else
      dunstify "Music Paused" -t 5000 -r "$msgID" -u "normal"
    fi

    spot_status="$current_status"
    previous_metadata="$current_metadata"
  fi

  # Sleep for a short interval before checking again
  sleep 1
done
