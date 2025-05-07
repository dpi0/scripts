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
    -F "title=🟢 Finished Backup" \
    -F "message=$msg" > /dev/null
}

# Build filters to identify containers to ignore
FILTERS=()
for container in "${IGNORE_CONTAINERS[@]}"; do
  FILTERS+=("--filter" "name=${container}")
done

IGNORED=$(docker ps -a -q "${FILTERS[@]}" 2> /dev/null)
ALL_STOPPED=$(docker ps -a -q -f "status=exited" 2> /dev/null)
TO_START=$(comm -23 <(echo "$ALL_STOPPED" | sort) <(echo "$IGNORED" | sort))

if [ -n "$TO_START" ]; then
  STARTED_NAMES=$(docker inspect --format '{{.Name}}' $TO_START 2> /dev/null | sed 's#^/##' | paste -sd ' ' -)
  docker start $TO_START > /dev/null 2>&1
  notify "🔵 Started containers: $STARTED_NAMES."
else
  notify "🟡 No containers were started."
fi
