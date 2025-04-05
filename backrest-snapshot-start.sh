#!/usr/bin/env bash

ENV_FILE="${PWD}/.env"

if [[ -f "$ENV_FILE" ]]; then
  export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | xargs -d '\n')
else
  echo "Error: Environment file not found at $ENV_FILE" >&2
  exit 1
fi

NOTIFY_URL="${NOTIFY_APP_URL}/message?token=${NOTIFY_BACKREST_TOKEN}"
NOTIFY_TITLE="🛖 Arch Home Snapshot Start"
NOTIFY_MESSAGE="🟥 Stopping docker containers for backup."

# Function to notify via webhook
notify() {
  curl -s "$NOTIFY_URL" \
    -F "title=$NOTIFY_TITLE" \
    -F "message=$NOTIFY_MESSAGE"
}

# Get all running container IDs
all_containers=$(docker ps --quiet)

# Get IDs of containers to ignore
ignore_containers=$(docker ps --quiet \
  --filter "name=backrest" \
  --filter "name=nginx" \
  --filter "name=caddy")

# Find containers to stop (all containers except ignored ones)
containers_to_stop=$(comm -23 <(echo "$all_containers" | sort) <(echo "$ignore_containers" | sort))

# Stop the containers
if [ -n "$containers_to_stop" ]; then
  notify
  docker stop $containers_to_stop
else
  echo "No containers to stop."
fi
