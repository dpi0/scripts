#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$GOTIFY_CONTAINER_MANAGE_TOKEN
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
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟢 Starting Containers" \
    --message "Services will be working soon. $RESTARTED_NAMES."
else
  "$HOME/scripts/helpers/notify.sh" \
    --token "$TOKEN" \
    --title "🟡 No containers were restarted." \
    --message "Nothing was found to start."
fi
