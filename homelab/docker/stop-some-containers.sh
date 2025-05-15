#!/usr/bin/env bash

ENV_FILE="/home/dpi0/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$GOTIFY_CONTAINER_MANAGE_TOKEN
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
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🔴 Stopping Containers..." \
    --message "These services will be temporarily unavailable: $STOPPED_NAMES."
else
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟡 No target containers were running or found to stop." \
    --message "Nothing could be stopped."
fi
