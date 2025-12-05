#!/usr/bin/env bash

THEME="$HOME/.dotfiles/rofi/themes/minimal-fullscreen.rasi"

launch() {
  local workspace="$1"
  local url="$2"

  hyprctl dispatch workspace "$workspace"
  firefox --new-window "$url"
  # below is to not have firefox open in fullscreen, blocking waybar
  sleep 0.2
  hyprctl dispatch fullscreen 1
  hyprctl dispatch fullscreen 1 # have to run twice
}

launch2() {
  local workspace="$1"
  local url="$2"

  hyprctl dispatch workspace "$workspace"
  ~/temp/webapp.sh "$url"
  hyprctl dispatch fullscreen 1
  hyprctl dispatch fullscreen 1 # have to run twice

}

declare -A actions=(
  ["󱊮 Monkeytype"]="7|https://monkeytype.com"
  [" DeepSeek"]="8|https://chat.deepseek.com/"
  ["󰧑 Claude"]="9|https://claude.ai"
  [" ChatGPT"]="3|https://chat.openai.com"
  [" Discord"]="12|https://discord.com/channels/@me"
  [" Gemini"]="10|https://aistudio.google.com/prompts/new_chat"
  ["󰇞 Excalidraw"]="14|https://excalidraw.com"
  ["󰚩 Mistral"]="6|https://chat.mistral.ai"
)

menu=$(printf "%s\n" "${!actions[@]}")
chosen=$(echo -e "$menu" | rofi -no-config -dmenu -i -theme "$THEME" -theme-str '* { font: "JetBrainsMono NF 20"; }')

if [[ -n "$chosen" && -n "${actions[$chosen]}" ]]; then
  IFS='|' read -r workspace url <<<"${actions[$chosen]}"
  launch "$workspace" "$url"
fi
