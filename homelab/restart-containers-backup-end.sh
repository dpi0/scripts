#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

notify() {
  local msg="$1"
  curl -s "${NOTIFY_URL}/message?token=${NOTIFY_TOKEN}" \
    -F "title=🟢 Finishing Backrest Snapshot" \
    -F "message=$msg" > /dev/null
}

# TARGET_CONTAINERS=(immich_server immich_redis immich_postgres)
TARGET_CONTAINERS=("$@")

if [ ${#TARGET_CONTAINERS[@]} -eq 0 ]; then
  echo "🔴 No containers specified to restart. Usage: $0 container1 container2 ..." >&2
  exit 1
fi

# Find exited target containers and get their container IDs
TO_START=$(docker ps -a --filter "status=exited" --format '{{.Names}} {{.ID}}' 2> /dev/null | awk '
  BEGIN { split("'"${TARGET_CONTAINERS[*]}"'", t); for (i in t) map[t[i]] = 1 }
  map[$1] { print $2 }
')

if [ -n "$TO_START" ]; then
  RESTARTED_NAMES=$(docker inspect --format '{{.Name}}' $TO_START 2> /dev/null | sed 's#^/##' | paste -sd ' ' -)
  docker start $TO_START > /dev/null 2>&1
  sleep 20 > /dev/null 2>&1
  notify "🔵 Restarting containers: $RESTARTED_NAMES. Services will be working soon."
else
  notify "🟡 No target containers were restarted."
fi
