#!/usr/bin/env bash

NOTIFY_URL="https://notify.dpi0.cloud/message?token=A3STeeMYgy3k401"
NOTIFY_TITLE="🛖 Arch Home Snapshot Start"
NOTIFY_MESSAGE="🟥 Stopping docker containers for backup. ARCH containers may be temporarily unavailable."

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
