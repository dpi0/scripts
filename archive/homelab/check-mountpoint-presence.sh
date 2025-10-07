#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

MOUNTPOINT="/hdd"
UUID="df47360a-eade-4956-a05d-4570a22b826c"
TOKEN=$ALERTMANAGER_TOKEN
NOTIFY_SCRIPT="$HOME/scripts/helpers/notify.sh"

if ! findmnt -rn --source UUID=$UUID >/dev/null; then
  "$NOTIFY_SCRIPT" \
    --token "${TOKEN}" \
    --title "🔴 $MOUNTPOINT disconnected at $(date '+%H:%M %d %b')" \
    --message "Fix!"
fi
