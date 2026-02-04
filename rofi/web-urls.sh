#!/usr/bin/env bash

open_in_browser() {
  local url="$1"
  local ws=1
  ws_addr=$(hyprctl clients -j | jq -r ".[] | select(.class==\"firefox\" and .workspace.id==$ws) | .address" | head -n1)
  [ -z "$ws_addr" ] && exit 1
  hyprctl dispatch focuswindow "address:$ws_addr"
  firefox --new-tab "$url"
}

declare -A actions=(
  [" Amazon"]="https://www.amazon.in/gp/cart/view.html?ref_=nav_cart"
  [" 1337x"]="https://1337x.to"
  ["󰟞 Letterboxd"]="https://letterboxd.com"
  ["󰊫 Gmail dvynsh24"]="https://mail.google.com/mail/u/0/"
  [" Proton Mail dpi0.dev"]="https://mail.proton.me/u/0/inbox/"
  [" Proton Mail divyansh.work"]="https://mail.proton.me/u/1/inbox/"
  [" Nerd Fonts - Icons"]="https://www.nerdfonts.com/cheat-sheet"
  ["󱌝 Iconify"]="https://icon-sets.iconify.design/?query=icon"
  [" Drive dvynsh24"]="https://drive.google.com/drive/u/0/"
  [" Drive dpi0.dev"]="https://drive.google.com/drive/u/1/"
  ["󰓇 Spotify Web"]="https://open.spotify.com"
  [" Notes"]="https://notes.home.i0w.xyz"
  ["󰁯 Backrest Backup TItan"]="http://localhost:9898"
  ["󰌁 Color Wheel"]="https://www.hslpicker.com/#398cf9"
  ["󰞅 EmojiDB"]="https://emojidb.org"
  ["󰿃 Choose a License - MIT"]="https://choosealicense.com/licenses/mit"
  ["󰦗 Cobalt Downloader"]="https://cobalt.tools"
  ["󰓅 Speed Test Cloudflare"]="https://speed.cloudflare.com"
  ["󰁯 Backrest Backup - 0x"]="https://backrest.home.i0w.xyz"
  [" qBittorrent - 0x"]="https://qb.home.i0w.xyz"
  ["󰎁 Jellyfin - 0x"]="https://jellyfin.home.i0w.xyz"
  [" Beszel - 0x"]="https://beszel.home.i0w.xyz"
  ["󰝚 Navidrome Music - 0x"]="https://music.home.i0w.xyz"
  [" Immich Photos - 0x"]="http://10.0.0.10:2283"
  [" Syncthing - 0x"]="https://syncthing.home.i0w.xyz"
  ["󰆕 Color Contrast Checker"]="https://coolors.co/contrast-checker/ffffff-000000"
  [" Compress Image Mazanoke"]="https://mazanoke.com/"
  ["󰑩 Router Gateway"]="http://10.0.0.1/cgi-bin/login.asp"
  [" ListenBrainz Scrobble"]="https://listenbrainz.org/user/molecule_/"
  [" Discord"]="https://discord.com/channels/@me"
  ["󰽉 Excalidraw"]="https://excalidraw.com/"
  [" last.fm Scrobble"]="https://www.last.fm/user/molecule_"
  [" GitHub Packages"]="https://github.com/dpi0?tab=packages"
  ["Cloudflare Domain Dashboard - DNS Records"]="https://dash.cloudflare.com/2852e4961c860e4705381269c2aeea94/i0w.xyz/dns/records"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -no-config -dmenu -i -theme "minimal-fullscreen" -theme-str '* { font: "JetBrainsMono NF 20"; }')

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
  open_in_browser "${actions[$chosen]}"
fi
