#!/usr/bin/env bash

msgID="7623"
color="#FF098EFF"
mic_volume="$(pamixer --default-source --get-volume)"
muted="$(pamixer --default-source --get-mute)"

if [ "$muted" == "true" ]; then
  dunstify " Muted" \
    -t 800 \
    -r "$msgID" \
    -u "critical" \
    -h string:fgcolor:"$color" \
    -h string:frcolor:"$color" \
    -h string:hlcolor:"$color"
else
  dunstify " Mic Volume: $mic_volume%" \
    -t 800 \
    -r "$msgID" \
    -h int:value:"$mic_volume" \
    -h string:fgcolor:"$color" \
    -h string:frcolor:"$color" \
    -h string:hlcolor:"$color"
fi

# Play sound
# canberra-gtk-play -i audio-volume-change -d "changeVolume"
