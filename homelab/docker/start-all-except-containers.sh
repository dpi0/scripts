#!/usr/bin/env bash

ENV_FILE="/home/dpi0/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$GOTIFY_CONTAINER_MANAGE_TOKEN
IGNORE_CONTAINERS=("$@")

if [ ${#IGNORE_CONTAINERS[@]} -eq 0 ]; then
  echo "🔴 No containers specified to ignore. Usage: $0 container1 container2 ..." >&2
  exit 1
fi

FILTERS=()
for container in "${IGNORE_CONTAINERS[@]}"; do
  FILTERS+=("--filter" "name=${container}")
done

IGNORED=$(docker ps -a -q "${FILTERS[@]}" 2> /dev/null)
ALL_STOPPED=$(docker ps -a -q -f "status=exited" 2> /dev/null)
TO_START=$(comm -23 <(echo "$ALL_STOPPED" | sort) <(echo "$IGNORED" | sort))

if [ -n "$TO_START" ]; then
  RESTARTED_NAMES=$(docker inspect --format '{{.Name}}' $TO_START 2> /dev/null | sed 's#^/##' | paste -sd ' ' -)
  docker start $TO_START > /dev/null 2>&1
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
