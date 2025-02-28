#!/usr/bin/env bash

color_red=#FF0000
color_green=#11ff00
LOG_FILE="$HOME/shutdown_night_go_to_sleep.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

acpi_output=$(acpi -b)
ac_status=$(echo "$acpi_output" | awk '{print $3}' | tr -d ',')
pct_now=$(echo "$acpi_output" | awk '{print $4}' | tr -d '%,,')

pct_low_threshold=25
pct_high_threshold=90

log "Battery Percentage: $pct_now%"

# If charging and above high threshold, raise dunstify warning.
if [[ $ac_status == "Charging" && $pct_now -gt $pct_high_threshold ]]; then
    dunstify -u critical -h string:fgcolor:"$color_green" -h string:frcolor:"$color_green" -h string:hlcolor:"$color_green" "Battery High, Disconnect" "Battery level is at ${pct_now}%."
    log "Notification: Battery High - ${pct_now}%"
fi

# If discharging and below low threshold, raise dunstify warning.
if [[ $ac_status == "Discharging" && $pct_now -lt $pct_low_threshold ]]; then
    dunstify -u critical -h string:fgcolor:"$color_red" -h string:frcolor:"$color_red" -h string:hlcolor:"$color_red" "Low Battery, Plug in" "Battery level is at ${pct_now}%."
    log "Notification: Low Battery - ${pct_now}%"
fi

dunstify -u critical -h string:fgcolor:"$color_green" -h string:frcolor:"$color_green" -h string:hlcolor:"$color_green" "Battery High, Disconnect" "Battery level is at ${pct_now}%."

