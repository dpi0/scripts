#!/usr/bin/env bash

NOTIFY_URL="https://notify.dpi0.cloud/message?token=A3STeeMYgy3k401"
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
