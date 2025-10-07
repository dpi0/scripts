#!/usr/bin/env bash

nmcli_check=$(nmcli networking connectivity)
working_color="#57FF00"
bad_color="#FF0000"
warning_color="#FFCC32"

notify_ok() {
	dunstify -a "connectivity-check" \
		"🟢 Internet: Verified" \
		-u low \
		-t 2000 \
		-r "1231" \
		-h string:fgcolor:"$working_color" \
		-h string:frcolor:"$working_color" \
		-h string:hlcolor:"$working_color"
}

notify_warn() {
	dunstify -a "connectivity-check" \
		"🟡 Network present but limited: $1" \
		-u low \
		-t 2000 \
		-r "1232" \
		-h string:fgcolor:"$warning_color" \
		-h string:frcolor:"$warning_color" \
		-h string:hlcolor:"$warning_color"
}

notify_fail() {
	dunstify -a "connectivity-check" \
		"🔴 No internet." \
		-u low \
		-t 2000 \
		-r "1233" \
		-h string:fgcolor:"$bad_color" \
		-h string:frcolor:"$bad_color" \
		-h string:hlcolor:"$bad_color"
}

# Primary check via NetworkManager
# if [[ "$nmcli_check" == "full" ]]; then
# 	notify_ok
# 	exit 0
# fi

# Fallback: try to resolve external IP via curl
if ip=$(curl -s --max-time 2 https://ip.me); then
	if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		notify_ok
		exit 0
	else
		notify_warn "$nmcli_check (Invalid IP: $ip)"
		exit 1
	fi
else
	notify_fail "$nmcli_check"
	exit 2
fi
