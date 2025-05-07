#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

# IGNORE_CONTAINERS=(backrest caddy redlib gotify healthchecks)
IGNORE_CONTAINERS=("$@")

if [ ${#IGNORE_CONTAINERS[@]} -eq 0 ]; then
  echo "🔴 No containers specified to ignore. Usage: $0 container1 container2 ..." >&2
  exit 1
fi

notify() {
  local msg="$1"
  curl -s "${NOTIFY_URL}/message?token=${NOTIFY_TOKEN}" \
    -F "title=🟠 Starting Backup..." \
    -F "message=$msg" > /dev/null
}

FILTERS=()
for container in "${IGNORE_CONTAINERS[@]}"; do
  FILTERS+=("--filter" "name=${container}")
done

IGNORED=$(docker ps -q "${FILTERS[@]}" 2> /dev/null)
RUNNING=$(docker ps -q 2> /dev/null)
TO_STOP=$(comm -23 <(echo "$RUNNING" | sort) <(echo "$IGNORED" | sort))

if [ -n "$TO_STOP" ]; then
  STOPPED_NAMES=$(docker inspect --format '{{.Name}}' $TO_STOP 2> /dev/null | sed 's#^/##' | paste -sd ' ' -)
  docker stop $TO_STOP > /dev/null 2>&1
  notify "🔴 Stopping containers: $STOPPED_NAMES. These services will be temporarily unavailable."
else
  notify "🟡 No containers were stopped."
fi
