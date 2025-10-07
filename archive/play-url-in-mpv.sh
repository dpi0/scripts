#!/usr/bin/env bash

# grab the current clipboard text
url=$(wl-paste --no-newline)

# either http or https will work
if [[ "$url" =~ ^https?:// ]]; then
	# the valid url must contain these keywords anywhere in it
	if echo "$url" | grep -Eiq 'youtube\.com|youtu\.be|localhost:1010|invidious|yew\.tube|video|play|vid'; then
		mpv "$url"
	else
		notify-send "URL not allowed" "URL does not match allowed domains/keywords"
		exit 1
	fi
else
	notify-send "Invalid URL" "Clipboard does not contain a valid http(s) URL"
	exit 1
fi
