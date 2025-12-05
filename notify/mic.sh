#!/usr/bin/env bash

msgID=7623
color="#FF098EFF"

for arg in "$@"; do
  case "$arg" in
  --up=*)
    step="${arg#*=}"
    pamixer --default-source -i "$step"
    ;;
  --down=*)
    step="${arg#*=}"
    pamixer --default-source -d "$step"
    ;;
  --mute)
    pamixer --default-source -t
    ;;
  esac
done

mic_volume="$(pamixer --default-source --get-volume)"
muted="$(pamixer --default-source --get-mute)"

if [ "$muted" = "true" ]; then
  dunstify "   Mic Muted" \
    -t 800 \
    -r "$msgID" \
    -u "critical" \
    -h string:fgcolor:"$color" \
    -h string:hlcolor:"$color"
else
  dunstify "Mic Input: ${mic_volume}%" \
    -t 800 \
    -r "$msgID" \
    -h int:value:"$mic_volume" \
    -h string:fgcolor:"$color" \
    -h string:hlcolor:"$color"
fi
