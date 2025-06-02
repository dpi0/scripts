#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

STOPPED=$(docker ps -q -f "status=exited" 2> /dev/null)

if [ -n "$STOPPED" ]; then
  docker start $STOPPED > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  "$NOTIFY_SCRIPT" \
    --message "🟢 Starting All Containers on $HOSTNAME" \
else
  "$NOTIFY_SCRIPT" \
    --message "🟡 No containers were restarted on $HOSTNAME." \
fi
