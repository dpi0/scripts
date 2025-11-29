#!/usr/bin/env bash

# Check if any wireless device is currently *not* soft-blocked
# If a match is found, it means at least one radio is ON.
# So, we turn everything OFF.
# And ENABLE Airplane Mode.
if rfkill list | grep -q "Soft blocked: no"; then
  notify-send "✈️ Airplane Mode: On" "All wireless connections are now disabled."
  rfkill block all
else
  notify-send "🛜 Airplane Mode: Off" "Wireless connections are now enabled."
  rfkill unblock all
fi
