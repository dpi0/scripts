#!/usr/bin/env bash

NOTIFY_ID=9910

# Check if any wireless device is currently *not* soft-blocked
# If a match is found, it means at least one radio is ON.
# So, we turn everything OFF.
# And ENABLE Airplane Mode.
if rfkill list | grep -q "Soft blocked: no"; then
  rfkill block all
  dunstify -u normal -r "$NOTIFY_ID" \
    "✈️ 🚫 Airplane Mode: On" \
    "All wireless connections are now disabled."
else
  # Turn airplane mode OFF
  rfkill unblock all
  dunstify -u normal -r "$NOTIFY_ID" \
    "🌐 Airplane Mode: Off" \
    "Wireless connections are now enabled."
fi
