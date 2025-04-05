#!/usr/bin/env bash

ENV_FILE="${PWD}/.env"

if [[ -f "$ENV_FILE" ]]; then
  export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | xargs -d '\n')
else
  echo "Error: Environment file not found at $ENV_FILE" >&2
  exit 1
fi

NOTIFY_URL="${NOTIFY_APP_URL}/message?token=${NOTIFY_BACKREST_TOKEN}"
NOTIFY_TITLE="🛖 Arch Home Snapshot End"
NOTIFY_MESSAGE="🟩 Restarting docker containers."

# Function to notify via webhook
notify() {
  curl -s "$NOTIFY_URL" \
    -F "title=$NOTIFY_TITLE" \
    -F "message=$NOTIFY_MESSAGE"
}

# Get all stopped container IDs
stopped_containers=$(docker ps --quiet --filter "status=exited")

# Check if there are any stopped containers
if [ -n "$stopped_containers" ]; then
  docker start $stopped_containers
else
  echo "No stopped containers to start."
fi

sleep 30

notify
