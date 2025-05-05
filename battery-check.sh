#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

BATTERY_LOW=18
BATTERY_HIGH=92
LOG_FILE="$HOME/.battery.log"
LOGGING_ENABLED=0
COLOR_RED="#FF0000"
COLOR_GREEN="#11FF00"

log() {
  [[ $LOGGING_ENABLED -eq 1 ]] && echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Get battery information
battery_info=$(acpi -b)
charging_status=$(echo "$battery_info" | grep -oE 'Charging|Discharging')
battery_percent=$(echo "$battery_info" | grep -oE '[0-9]+%' | tr -d '%')

log "Battery Percentage: $battery_percent%"

# Check battery conditions and send notifications if needed
if [[ "$charging_status" == "Charging" && $battery_percent -gt $BATTERY_HIGH ]]; then
  HIGH_TITLE="Battery High, Disconnect"
  HIGH_MESSAGE="Battery level is at ${battery_percent}%."
  dunstify -u critical \
    -h string:fgcolor:"$COLOR_GREEN" \
    -h string:frcolor:"$COLOR_GREEN" \
    -h string:hlcolor:"$COLOR_GREEN" \
    "$HIGH_TITLE" \
    "$HIGH_MESSAGE"
  log "Notification: Battery High - ${battery_percent}%"
  notify-phone --token "$NOTIFY_BATTERY_LEVEL_TOKEN" --title "$HIGH_TITLE" --message "$HIGH_MESSAGE"
elif [[ "$charging_status" == "Discharging" && $battery_percent -lt $BATTERY_LOW ]]; then
  LOW_TITLE="Low Battery, Plug in"
  LOW_MESSAGE="Battery level is at ${battery_percent}%."
  dunstify -u critical \
    -h string:fgcolor:"$COLOR_RED" \
    -h string:frcolor:"$COLOR_RED" \
    -h string:hlcolor:"$COLOR_RED" \
    "$LOW_TITLE" \
    "$LOW_MESSAGE"
  log "Notification: Low Battery - ${battery_percent}%"
  notify-phone --token "$NOTIFY_BATTERY_LEVEL_TOKEN" --title "$LOW_TITLE" --message "$LOW_MESSAGE"
fi
