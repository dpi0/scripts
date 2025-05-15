#!/usr/bin/env bash

ENV_FILE="/home/dpi0/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$GOTIFY_CONTAINER_MANAGE_TOKEN
RUNNING=$(docker ps -q 2> /dev/null)

if [ -n "$RUNNING" ]; then
  docker stop $RUNNING > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🔴 Stopping All Containers..." \
    --message "No service will available for a while"
else
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟡 No target containers were running or found to stop." \
    --message "Nothing could be stopped."
fi
