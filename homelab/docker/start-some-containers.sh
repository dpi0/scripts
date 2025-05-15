#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=${GOTIFY_CONTAINER_MANAGE_TOKEN}
NOTIFY_SCRIPT="$HOME/scripts/helpers/notify.sh"

if [ "$#" -eq 0 ]; then
  echo "🔴 No containers specified to start. Usage: $1 container1 container2 ..." >&2
  exit 1
fi

STARTED=()
NOT_FOUND=()

for container in "$@"; do
  if docker ps -a -q -f name="^${container}$" | grep -q .; then
    if ! docker ps -q -f name="^${container}$" | grep -q .; then
      docker start "$container" > /dev/null 2>&1 && STARTED+=("$container")
    fi
  else
    NOT_FOUND+=("$container")
  fi
done

if [ "${#STARTED[@]}" -gt 0 ]; then
  "$NOTIFY_SCRIPT" \
    --token "${TOKEN}" \
    --title "🟢 Started some containers on $HOSTNAME" \
    --message "Started: ${STARTED[*]}"
fi

if [ "${#NOT_FOUND[@]}" -gt 0 ]; then
  "$NOTIFY_SCRIPT" \
    --token "${TOKEN}" \
    --title "🟡 No target containers were found to be running on $HOSTNAME." \
    --message "Not found: ${NOT_FOUND[*]}"
fi
