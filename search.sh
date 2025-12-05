#!/usr/bin/env bash

clipboard_text="$(/usr/bin/wl-paste)"

open_search() {
	local url="$1"
	xdg-open "$url"
	hyprctl dispatch workspace 1
}

usage() {
	echo "Usage: $0 {google|youtube}" >&2
	exit 1
}

case "$1" in
google)
	open_search "https://www.google.com/search?udm=14&q=${clipboard_text}&num=50"
	;;
youtube)
	open_search "https://www.youtube.com/results?search_query=${clipboard_text}"
	;;
*)
	usage
	;;
esac
