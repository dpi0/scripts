#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

notify() {
  local msg="$1"
  curl -s "${NOTIFY_URL}/message?token=${NOTIFY_TOKEN}" \
    -F "title=🟠 Starting Backup..." \
    -F "message=$msg" > /dev/null
}

RUNNING=$(docker ps -q 2> /dev/null)

if [ -n "$RUNNING" ]; then
  docker stop $RUNNING > /dev/null 2>&1
  notify "🔴 Stopping all docker containers. No services will available for a while."
else
  notify "🟡 No target containers were running or found to stop."
fi
