#!/usr/bin/env bash

if pactl list sinks | grep -i "active port" | grep -qi "headphone\|earphone"; then
	echo '{"text": "󰋋 ", "tooltip": "Headphones connected"}'
else
	echo '{"text": ""}'
fi
