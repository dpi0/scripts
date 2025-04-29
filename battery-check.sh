#!/usr/bin/env bash

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
  dunstify -u critical \
    -h string:fgcolor:"$COLOR_GREEN" \
    -h string:frcolor:"$COLOR_GREEN" \
    -h string:hlcolor:"$COLOR_GREEN" \
    "Battery High, Disconnect" \
    "Battery level is at ${battery_percent}%."
  log "Notification: Battery High - ${battery_percent}%"
elif [[ "$charging_status" == "Discharging" && $battery_percent -lt $BATTERY_LOW ]]; then
  dunstify -u critical \
    -h string:fgcolor:"$COLOR_RED" \
    -h string:frcolor:"$COLOR_RED" \
    -h string:hlcolor:"$COLOR_RED" \
    "Low Battery, Plug in" \
    "Battery level is at ${battery_percent}%."
  log "Notification: Low Battery - ${battery_percent}%"
fi
