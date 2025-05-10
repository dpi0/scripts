#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

BATTERY_LOW=18
BATTERY_HIGH=92
LOG_FILE="$HOME/.battery.log"
LOGGING_ENABLED=0
COLOR_RED="#FF0000"
COLOR_GREEN="#11FF00"
URL=$GOTIFY_URL
TOKEN=$GOTIFY_BATTERY_CHECK_TOKEN

log() {
  [[ $LOGGING_ENABLED -eq 1 ]] && echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

notify() {
  local title="$1"
  local message="$2"
  local color="$3"

  dunstify -u critical \
    -h string:fgcolor:"$color" \
    -h string:frcolor:"$color" \
    -h string:hlcolor:"$color" \
    "$title" "$message"

  "$HOME/scripts/helpers/notify.sh" --token "$TOKEN" --title "$title" --message "$message"
  log "Notification: $title - $message"
}

# Parse battery info
battery_info=$(acpi -b)
charging_status=$(grep -oE 'Charging|Discharging' <<< "$battery_info")
battery_percent=$(grep -oE '[0-9]+%' <<< "$battery_info" | tr -d '%')

log "Battery Percentage: $battery_percent%"

if [[ "$charging_status" == "Charging" && $battery_percent -gt $BATTERY_HIGH ]]; then
  notify "Battery High, Disconnect" "Battery level is at ${battery_percent}%." "$COLOR_GREEN"
elif [[ "$charging_status" == "Discharging" && $battery_percent -lt $BATTERY_LOW ]]; then
  notify "Low Battery, Plug in" "Battery level is at ${battery_percent}%." "$COLOR_RED"
fi
