#!/usr/bin/env bash

# https://wiki.archlinux.org/title/Dark_mode_switching#gsettings

# easiest way is to use a user's systemd.service with env vars defined in the systemd service

# Get the current user's environment variables for Wayland
# export DISPLAY=:0
# export XDG_RUNTIME_DIR="/run/user/$(id -u)"
# export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Function to set the theme
set_theme() {
  current_hour=$(date +%H)
  current_minute=$(date +%M)
  current_time=$((10#$current_hour * 60 + 10#$current_minute)) # Time in minutes

  light_start=$((6 * 60))     # 06:00 in minutes
  light_end=$((17 * 60 + 30)) # 17:30 in minutes

  if [ $current_time -ge $light_start ] && [ $current_time -lt $light_end ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  fi
}

# Main loop
while true; do
  set_theme
  sleep 120 # Check every 120 seconds
done
