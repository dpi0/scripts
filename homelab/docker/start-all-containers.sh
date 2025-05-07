#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

notify() {
  local msg="$1"
  curl -s "${NOTIFY_URL}/message?token=${NOTIFY_TOKEN}" \
    -F "title=🟢 Finished Backup" \
    -F "message=$msg" > /dev/null
}

STOPPED=$(docker ps -q -f "status=exited" 2> /dev/null)

if [ -n "$STOPPED" ]; then
  docker start $STOPPED > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  notify "🔵 Restarting docker containers. Services will be working soon."
else
  notify "🟡 No containers were restarted."
fi
