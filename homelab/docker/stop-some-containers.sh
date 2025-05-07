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

# TARGET_CONTAINERS=(immich_server immich_redis immich_postgres)
TARGET_CONTAINERS=("$@")

if [ ${#TARGET_CONTAINERS[@]} -eq 0 ]; then
  echo "🔴 No containers specified to stop. Usage: $0 container1 container2 ..." >&2
  exit 1
fi

# Resolve container IDs for the specific targets that are currently running
TO_STOP=$(docker ps --filter "status=running" --format '{{.Names}} {{.ID}}' 2> /dev/null | awk '
  BEGIN { split("'"${TARGET_CONTAINERS[*]}"'", t); for (i in t) map[t[i]] = 1 }
  map[$1] { print $2 }
')

if [ -n "$TO_STOP" ]; then
  STOPPED_NAMES=$(docker inspect --format '{{.Name}}' $TO_STOP 2> /dev/null | sed 's#^/##' | paste -sd ' ' -)
  docker stop $TO_STOP > /dev/null 2>&1
  notify "🔴 Stopping containers: $STOPPED_NAMES. These services will be temporarily unavailable."
else
  notify "🟡 No target containers were running or found to stop."
fi
