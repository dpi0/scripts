#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

IGNORE_CONTAINERS=("$@")

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
  "$NOTIFY_SCRIPT" \
    --message "🔴 Stopping some containers on $HOSTNAME. These services will be temporarily unavailable: $STOPPED_NAMES."
else
  "$NOTIFY_SCRIPT" \
    --message "🟡 No target containers were running or found to stop on $HOSTNAME" \
fi
