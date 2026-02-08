#!/usr/bin/env bash

web_app_launch() {
  hyprctl dispatch workspace "$1"
  firefox --new-window "$2"
}

web_url_launch() {
  ws_addr=$(hyprctl clients -j | jq -r \
    ".[] | select(.class==\"firefox\" and .workspace.id==$1) | .address" |
    head -n1)

  [[ -z "$ws_addr" ]] && firefox --new-window "$2" && return

  hyprctl dispatch focuswindow "address:$ws_addr"
  firefox --new-tab "$2"
}

declare -A actions=(
  ["󱊮 Monkeytype"]="app|7|https://monkeytype.com"
  [" DeepSeek"]="app|8|https://chat.deepseek.com/"
  ["󰧑 Claude"]="app|9|https://claude.ai"
  [" ChatGPT"]="app|3|https://chat.openai.com"
  [" Discord"]="1app|2|https://discord.com/channels/@me"
  [" Gemini"]="1app|0|https://aistudio.google.com/prompts/new_chat"
  ["󰇞 Excalidraw"]="1app|4|https://excalidraw.com"
  ["󰚩 Mistral"]="app|6|https://chat.mistral.ai"

  [" Amazon"]="url|1|https://www.amazon.in/gp/cart/view.html?ref_=nav_cart"
  [" 1337x"]="url|1|https://1337x.to"
  ["󰟞 Letterboxd"]="url|1|https://letterboxd.com"
  ["󰊫 Gmail dvynsh24"]="url|1|https://mail.google.com/mail/u/0/"
  [" Proton Mail dpi0.dev"]="url|1|https://mail.proton.me/u/0/inbox/"
  [" Proton Mail divyansh.work"]="url|1|https://mail.proton.me/u/1/inbox/"
  [" Nerd Fonts - Icons"]="url|1|https://www.nerdfonts.com/cheat-sheet"
  ["󱌝 Iconify"]="url|1|https://icon-sets.iconify.design/?query=icon"
  [" Drive dvynsh24"]="url|1|https://drive.google.com/drive/u/0/"
  [" Drive dpi0.dev"]="url|1|https://drive.google.com/drive/u/1/"
  ["󰓇 Spotify Web"]="url|1|https://open.spotify.com"
  [" Notes"]="url|1|https://notes.home.i0w.xyz"
  ["󰁯 Backrest Backup Titan"]="http://localhost:9898"
  ["󰌁 Color Wheel"]="url|1|https://www.hslpicker.com/#398cf9"
  ["󰞅 EmojiDB"]="url|1|https://emojidb.org"
  ["󰿃 Choose a License - MIT"]="iwurl{1{}}://choosealicense.com/licenses/mit"
  ["󰦗 Cobalt Downloader"]="url|1|https://cobalt.tools"
  ["󰓅 Speed Test Cloudflare"]="url|1|https://speed.cloudflare.com"
  ["󰁯 Backrest Backup - 0x"]="url|1|https://backrest.home.i0w.xyz"
  [" qBittorrent - 0x"]="url|1|https://qb.home.i0w.xyz"
  ["󰎁 Jellyfin - 0x"]="url|1|https://jellyfin.home.i0w.xyz"
  [" Beszel - 0x"]="url|1|https://beszel.home.i0w.xyz"
  ["󰝚 Navidrome Music - 0x"]="url|1|https://music.home.i0w.xyz"
  [" Immich Photos - 0x"]="http://10.0.0.10:2283"
  [" Syncthing - 0x"]="url|1|https://syncthing.home.i0w.xyz"
  ["󰆕 Color Contrast Checker"]="url|1|https://coolors.co/contrast-checker/ffffff-000000"
  [" Compress Image Mazanoke"]="url|1|https://mazanoke.com/"
  ["󰑩 Router Gateway"]="http://10.0.0.1/cgi-bin/login.asp"
  [" ListenBrainz Scrobble"]="url|1|https://listenbrainz.org/user/molecule_/"
  [" Discord"]="url|1|https://discord.com/channels/@me"
  ["󰽉 Excalidraw"]="url|1|https://excalidraw.com/"
  [" last.fm Scrobble"]="url|1|https://www.last.fm/user/molecule_"
  [" GitHub Packages"]="url|1|https://github.com/dpi0?tab=packages"
  ["󰇖 Cloudflare Domain Dashboard - DNS Records"]="url|1|https://dash.cloudflare.com/2852e4961c860e4705381269c2aeea94/i0w.xyz/dns/records"
  ["󰖣 WhatsApp Web"]="url|1|https://web.whatsapp.com"
  [" Telegram Web"]="url|1|https://web.telegram.org/a/"
  [" Docker Hub Repositories/Packages"]="url|1|https://hub.docker.com/repositories/dpi0"
)

chosen=$(printf "%s\n" "${!actions[@]}" | rofi -no-config -dmenu -i \
  -theme "minimal-fullscreen" \
  -theme-str '* { font: "JetBrainsMono NF 20"; }')

[[ -z "$chosen" ]] && exit

IFS='|' read -r mode ws url <<<"${actions[$chosen]}"

[[ "$mode" == "app" ]] && web_app_launch "$ws" "$url" || web_url_launch "$ws" "$url"
