#!/usr/bin/env bash

msgID=31232
accent="#EBBB2D"

for arg in "$@"; do
  case "$arg" in
  --up=*)
    step="${arg#*=}"
    brightnessctl set "${step}%+"
    ;;
  --down=*)
    step="${arg#*=}"
    brightnessctl set "${step}%-"
    ;;
  *)
    brightnessctl "$arg"
    ;;
  esac
done

# NOTE: This block has to be below the above args
current="$(brightnessctl g)"
max="$(brightnessctl m)"
percent=$((current * 100 / max))

dunstify -a "changeBrightness" \
  "Brightness: ${percent}%" \
  -u low \
  -t 700 \
  -r "$msgID" \
  -h int:value:"$percent" \
  -h string:fgcolor:"$accent" \
  -h string:hlcolor:"$accent"
