#!/usr/bin/env bash

THEME="$HOME/.dotfiles/rofi/themes/minimal-fullscreen-jetbrains-font.rasi"

open_in_browser() {
	local url="$1"
	xdg-open "$url"
	hyprctl dispatch workspace 1
}

declare -A actions=(
	["󰊫 Gmail dvynsh24"]="https://mail.google.com/mail/u/0/"
	[" Proton Mail dpi0.dev"]="https://mail.proton.me/u/0/inbox/"
	[" Proton Mail divyansh.work"]="https://mail.proton.me/u/1/inbox/"
	[" Amazon"]="https://amazon.in"
	[" 1337x"]="https://1337x.to"
	[" qBittorrent Homelab"]="http://qb.home.i0w.xyz"
	["󰎁 Jellyfin Homelab"]="http://j.home.i0w.xyz"
	[" Beszel Homelab"]="http://z.home.i0w.xyz"
	["󰟞 Letterboxd"]="https://letterboxd.com"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -no-config -dmenu -i -theme "$THEME")

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
	open_in_browser "${actions[$chosen]}"
fi
