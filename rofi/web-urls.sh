#!/usr/bin/env bash

THEME="$HOME/.dotfiles/rofi/themes/minimal-fullscreen-jetbrains-font.rasi"

open_in_browser() {
  local url="$1"
  xdg-open "$url"
  hyprctl dispatch workspace 1
}

declare -A actions=(
  [" Amazon"]="https://www.amazon.in/gp/cart/view.html?ref_=nav_cart"
  [" 1337x"]="https://1337x.to"
  ["󰟞 Letterboxd"]="https://letterboxd.com"
  ["󰊫 Gmail dvynsh24"]="https://mail.google.com/mail/u/0/"
  [" Proton Mail dpi0.dev"]="https://mail.proton.me/u/0/inbox/"
  [" Proton Mail divyansh.work"]="https://mail.proton.me/u/1/inbox/"
  [" qBittorrent Homelab"]="https://qb.home.i0w.xyz"
  ["󰎁 Jellyfin Homelab"]="https://jellyfin.home.i0w.xyz"
  [" Beszel Homelab"]="https://beszel.home.i0w.xyz"
  ["󰎚 Memos Homelab"]="https://memos.home.i0w.xyz"
  [" Nerd Fonts - Icons"]="https://www.nerdfonts.com/cheat-sheet"
  ["󱌝 Iconify"]="https://icon-sets.iconify.design/?query=icon"
  [" Drive dvynsh24"]="https://drive.google.com/drive/u/0/"
  [" Drive dpi0.dev"]="https://drive.google.com/drive/u/1/"
  ["󰓇 Spotify"]="https://open.spotify.com"
  [" Memos Notes"]="https://memos.home.i0w.xyz"
  ["󰁯 Backrest Backup TItan"]="http://localhost:9898"
  ["󰁯 Backrest Backup Homelab"]="https://backrest.home.i0w.xyz"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -no-config -dmenu -i -theme "$THEME")

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
  open_in_browser "${actions[$chosen]}"
fi
