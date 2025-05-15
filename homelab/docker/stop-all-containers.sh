#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=${GOTIFY_CONTAINER_MANAGE_TOKEN}
NOTIFY_SCRIPT="$HOME/scripts/helpers/notify.sh"
RUNNING=$(docker ps -q 2> /dev/null)

if [ -n "$RUNNING" ]; then
  docker stop $RUNNING > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  "$NOTIFY_SCRIPT" \
    --token "${TOKEN}" \
    --title "🔴 Stopping All Containers on $HOSTNAME..." \
    --message "No service will be available for a while."
else
  "$NOTIFY_SCRIPT" \
    --token "${TOKEN}" \
    --title "🟡 No target containers were running or found to stop on $HOSTNAME." \
    --message "Nothing was stopped."
fi
