#!/usr/bin/env bash

notify() {
	dunstify -a "connectivity-check" -u "$1" -t 2000 "$2" "$3"
}

if ip=$(curl -s --max-time 2 https://ip.me); then
	if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		notify low "🟢 Internet: Verified" "$ip"
		exit 0
	else
		notify low "🟡 Network limited" "Invalid IP: $ip"
		exit 1
	fi
else
	notify critical "🔴 No internet" ""
	exit 2
fi
