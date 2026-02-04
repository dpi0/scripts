#!/usr/bin/env bash

SCRIPTS="$HOME/scripts"

declare -A actions=(
  ["󱛄 Restart NetworkManager"]="pkexec systemctl restart NetworkManager"
  ["󰸉 Change Wallpaper"]="$SCRIPTS/rofi/swww-wallpaper.sh"
  ["󰱽 Find Files"]="$SCRIPTS/rofi/file-finder.sh"
  ["󰹑 Screenshot"]="$SCRIPTS/rofi/screenshot.sh"
  ["󰪚 Calculator"]="$SCRIPTS/rofi/calculator.sh"
  ["󰣀 SSH"]="$SCRIPTS/rofi/ssh.sh"
  ["󰤆 Power Menu"]="$SCRIPTS/rofi/power-menu.sh"
  ["󰞅 Emoji"]="$SCRIPTS/rofi/emoji.sh"
  [" Color Picker"]="$SCRIPTS/color-picker.sh"
  ["󰀝 Toggle Airplane Mode"]="$SCRIPTS/toggle-airplane-mode.sh"
  ["󱘖 Check Internet Connection"]="$SCRIPTS/check-internet-connection.sh"
  ["󰔎 Toggle Light/Dark Mode"]="$SCRIPTS/toggle-light-dark-mode.sh"
  [" Clipboard"]="$SCRIPTS/rofi/clipboard.sh"
  ["󰲝 NetworkManager GUI"]="nm-connection-editor"
  ["󰖟 Web URLs"]="$SCRIPTS/rofi/web-urls.sh"
  [" Apps"]="$SCRIPTS/rofi/apps.sh"
  ["󰲋 Binaries"]="$SCRIPTS/rofi/binaries.sh"
  ["󰖱 Show All Windows"]="$SCRIPTS/rofi/window.sh"
  [" Web Apps"]="$SCRIPTS/rofi/web-apps.sh"
  ["󰖪 Toggle Wi-Fi Connection"]="$SCRIPTS/rofi/web-apps.sh"
  [" Mount Devices"]="$SCRIPTS/rofi/mount.sh"
  [" Pacman Install"]="$SCRIPTS/rofi/pacman-install.sh"
  [" Mount Samba"]="$SCRIPTS/rofi/mount-samba.sh"
  ["󰻃 Screen Record"]="$SCRIPTS/screen-record.sh"
  [" Quick Note"]="$SCRIPTS/quick-note-nvim.sh"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -no-config -dmenu -i -theme "minimal-fullscreen" -theme-str '* { font: "JetBrainsMono NF 20"; }')

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
  eval "${actions[$chosen]}"
fi
