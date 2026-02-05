#!/usr/bin/env bash

msgID="9981"
player="spotify"

action=""
for arg in "$@"; do
	case "$arg" in
	--player=*)
		player="${arg#*=}"
		;;
	*)
		action="$arg"
		;;
	esac
done

IFS=',' read -ra PLAYERS <<<"$player"

resolve_player() {
	for p in "${PLAYERS[@]}"; do
		match=$(playerctl -l 2>/dev/null | grep -m1 "^$p")
		[ -n "$match" ] && echo "$match" && return
	done
}

resolved_player=$(resolve_player)
[ -z "$resolved_player" ] && resolved_player="$player"
player="$resolved_player"

fmt_time() {
	local total="$1"
	[ -z "$total" ] && total=0
	local m=$((total / 60))
	local s=$((total % 60))
	printf "%d:%02d" "$m" "$s"
}

send_notif() {
	local status title artist icon

	status=$(playerctl --player="$player" status 2>/dev/null)

	if [ -z "$status" ] || [ "$status" = "Stopped" ]; then
		dunstify --urgency low -r "$msgID" "No media playing" ""
		return
	fi

	title=$(playerctl --player="$player" metadata xesam:title 2>/dev/null)
	artist=$(playerctl --player="$player" metadata xesam:artist 2>/dev/null)

	[ -z "$title" ] && title="Unknown title"
	[ -z "$artist" ] && artist="Unknown artist"

	case "$status" in
	"Playing") icon="󰎇  " ;;
	"Paused") icon="  " ;;
	*) icon="" ;;
	esac

	dunstify --urgency low -r "$msgID" "$icon$status" "$title – $artist"
}

case "$action" in
play-pause)
	playerctl --player="$player" play-pause
	sleep 0.1
	send_notif
	;;
next)
	playerctl --player="$player" next
	sleep 0.1
	send_notif
	;;
prev)
	playerctl --player="$player" previous
	sleep 0.1
	send_notif
	;;
esac
