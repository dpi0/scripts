#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

RUNNING=$(docker ps -q 2> /dev/null)

if [ -n "$RUNNING" ]; then
  docker stop $RUNNING > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  "$NOTIFY_SCRIPT" \
    --message "🔴 Stopping All Containers on $HOSTNAME..." \
else
  "$NOTIFY_SCRIPT" \
    --message "🟡 No target containers were running or found to stop on $HOSTNAME." \
fi
