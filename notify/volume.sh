#!/usr/bin/env bash

msgID="2345"
accent="#4DF147"
timeout=800

for arg in "$@"; do
  case "$arg" in
  --up=*)
    step="${arg#*=}"
    pamixer -i "$step"
    ;;
  --down=*)
    step="${arg#*=}"
    pamixer -d "$step"
    ;;
  --mute)
    pamixer --toggle-mute
    ;;
  esac
done

volume="$(pamixer --get-volume)"
muted="$(pamixer --get-mute)"

player_exists="$(playerctl -l 2>/dev/null | head -n1)"
meta=""

if [ -n "$player_exists" ]; then
  track="$(playerctl metadata xesam:title 2>/dev/null)"
  artist="$(playerctl metadata xesam:artist 2>/dev/null)"

  if [ -n "$track" ] && [ -n "$artist" ]; then
    meta="$track – $artist"
  elif [ -n "$track" ]; then
    meta="$track"
  elif [ -n "$artist" ]; then
    meta="$artist"
  fi
fi

if [ "$muted" = "true" ]; then
  dunstify -u low "󰝟  Muted" \
    -t "$timeout" \
    -r "$msgID"
else
  if [ -n "$meta" ]; then
    dunstify -u low "Volume: ${volume}%" "$meta" \
      -t "$timeout" \
      -r "$msgID" \
      -h int:value:"$volume" \
      -h string:hlcolor:"$accent"
  else
    dunstify -u low "Volume: ${volume}%" \
      -t "$timeout" \
      -r "$msgID" \
      -h int:value:"$volume" \
      -h string:hlcolor:"$accent"
  fi
fi
