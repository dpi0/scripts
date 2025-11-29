#!/usr/bin/env bash

# Paths
GRIMBLAST="$HOME/bin/contrib/grimblast/grimblast"
UPLOADSCRIPT="$HOME/scripts/bin-upload.sh"
DIR="$HOME/Screenshots"
mkdir -p "$DIR"

# Required tools
REQUIRED_TOOLS=(
  "$GRIMBLAST"
  "$UPLOADSCRIPT"
  satty grim slurp hyprctl hyprpicker wl-copy jq notify-send
)

# Check for missing tools
missing=()
for tool in "${REQUIRED_TOOLS[@]}"; do
  if [[ "$tool" == /* ]]; then
    [ ! -x "$tool" ] && missing+=("$tool")
  else
    ! command -v "$tool" >/dev/null 2>&1 && missing+=("$tool")
  fi
done

if ((${#missing[@]})); then
  msg="Missing required tools:\n$(printf '%s\n' "${missing[@]}")"
  if command -v dunstify >/dev/null 2>&1; then
    dunstify "Screenshot Script Error" "$msg"
  else
    notify-send "Screenshot Script Error" "$msg"
  fi
  exit 1
fi

# Generate filename with timestamp and window title
make_filename() {
  local prefix="$1"
  local timestamp datestamp window_name
  timestamp="$(date +'%H-%M-%S')"
  datestamp="$(date +'%d-%b-%y')"
  window_name=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null)
  [ -z "$window_name" ] && window_name="NoWindow"
  window_name=$(echo "$window_name" | tr -d '"' | tr -c '[:alnum:]\ \-_' '_')
  echo "$DIR/${prefix} ${timestamp} ${datestamp} - ${window_name}.png"
}

# Upload helper
upload_and_notify() {
  local file="$1"
  if [ -f "$file" ]; then
    local url=$("$UPLOADSCRIPT" "$file")
    echo -n "$url" | wl-copy
    dunstify -i "$file" "Screenshot Uploaded" "$url"
  fi
}

# Action functions
area_screenshot() {
  local file
  file=$(make_filename "A")
  export SLURP_ARGS="-d"
  "$GRIMBLAST" --freeze copysave area "$file"
  [ -f "$file" ] && dunstify -i "$file" "Screenshot Saved" "$(basename "$file")"
}

fullscreen_screenshot() {
  local file
  file=$(make_filename "F")
  "$GRIMBLAST" --freeze copysave screen "$file"
  [ -f "$file" ] && dunstify -i "$file" "Screenshot Saved" "$(basename "$file")"
}

annotated_screenshot() {
  local file
  file=$(make_filename "N")
  "$GRIMBLAST" --freeze save screen - | satty --filename - --fullscreen --output-filename "$file"
  [ -f "$file" ] && dunstify -i "$file" "Annotated Screenshot Saved" "$(basename "$file")"
}

area_upload() {
  local file
  file=$(make_filename "UA")
  "$GRIMBLAST" --freeze save area "$file"
  upload_and_notify "$file"
}

fullscreen_upload() {
  local file
  file=$(make_filename "UF")
  "$GRIMBLAST" --freeze save screen "$file"
  upload_and_notify "$file"
}

annotated_upload() {
  local file
  file=$(make_filename "UN")
  "$GRIMBLAST" --freeze save screen - | satty --filename - --fullscreen --output-filename "$file"
  upload_and_notify "$file"
}

active_window_screenshot() {
  local file
  file=$(make_filename "A")
  export SLURP_ARGS="-d"
  "$GRIMBLAST" --freeze copysave active "$file"
  [ -f "$file" ] && dunstify -i "$file" "Screenshot Saved" "$(basename "$file")"
}

# Menu
declare -A actions=(
  ["󱞟  Area"]="area_screenshot"
  ["    Fullscreen"]="fullscreen_screenshot"
  ["󰽉  Annotated"]="annotated_screenshot"
  ["󰕒  Area Upload"]="area_upload"
  ["󰕒  Fullscreen Upload"]="fullscreen_upload"
  ["󰕒  Annotated Upload"]="annotated_upload"
  ["   Active Window"]="active_window_screenshot"
)

choice=$(printf "%s\n" "${!actions[@]}" | rofi -dmenu -p "Screenshot")
[ -z "$choice" ] && exit 0

# Execute chosen action
${actions[$choice]}
