#!/usr/bin/env bash

ENV_FILE="/home/dpi0/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$GOTIFY_CONTAINER_MANAGE_TOKEN
STOPPED=$(docker ps -q -f "status=exited" 2> /dev/null)

if [ -n "$STOPPED" ]; then
  docker start $STOPPED > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟢 Starting All Containers" \
    --message "Services will be working soon."
else
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟡 No containers were restarted." \
    --message "Nothing was found to start."
fi
