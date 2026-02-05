#!/usr/bin/env bash

clipboard_text="$(/usr/bin/wl-paste)"

open_search() {
	local url="$1"
	xdg-open "$url"
	hyprctl dispatch workspace 1
}

usage() {
	echo "Usage: $0 {google|youtube|brave|duckduckgo|oxford|letterboxd|reddit|wikipedia}" >&2
	exit 1
}

case "$1" in
google)
	open_search "https://www.google.com/search?udm=14&q=${clipboard_text}&num=50"
	;;
youtube)
	open_search "https://www.youtube.com/results?search_query=${clipboard_text}"
	;;
brave)
	open_search "https://search.brave.com/search?q=${clipboard_text}"
	;;
duckduckgo)
	open_search "https://duckduckgo.com/?q=${clipboard_text}&t=ffab"
	;;
oxford)
	open_search "https://www.oxfordlearnersdictionaries.com/definition/english/${clipboard_text}"
	;;
letterboxd)
	open_search "https://letterboxd.com/search/${clipboard_text}/?adult"
	;;
reddit)
	open_search "https://www.reddit.com/search/?q=${clipboard_text}"
	;;
wikipedia)
	open_search "https://en.wikipedia.org/w/index.php?search=${clipboard_text}"
	;;
*)
	usage
	;;
esac
