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
  echo "🔴 No containers specified to stop. Usage: $1 container1 container2 ..." >&2
  exit 1
fi

STOPPED=()
NOT_FOUND=()

for container in "$@"; do
  if docker ps -q -f name="^${container}$" | grep -q .; then
    docker stop "$container" > /dev/null 2>&1 && STOPPED+=("$container")
  else
    NOT_FOUND+=("$container")
  fi
done

if [ "${#STOPPED[@]}" -gt 0 ]; then
  "$NOTIFY_SCRIPT" \
    --token "$TOKEN" \
    --title "🛑 Stopped some containers on $HOSTNAME" \
    --message "Stopped: ${STOPPED[*]}"
fi

if [ "${#NOT_FOUND[@]}" -gt 0 ]; then
  "$NOTIFY_SCRIPT" \
    --token "$TOKEN" \
    --title "🟡 No target containers were running or found to stop on $HOSTNAME." \
    --message "Not running or not found: ${NOT_FOUND[*]}"
fi
