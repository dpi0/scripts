#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

TOKEN=$QB_NOTIFY_TOKEN
LOG_FILE=$QB_LOG_FILE_PATH

TORRENT_NAME=${1:-"Unknown Torrent"}
CATEGORY=${2:-"Unknown Category"}
CONTENT_PATH=${3:-"Unknown Content Path"}
PRIORITY=5

echo "----------------------------------------" >> "$LOG_FILE"
echo "Timestamp: $(date)" >> "$LOG_FILE"
echo "TORRENT_NAME: $TORRENT_NAME" >> "$LOG_FILE"
echo "CONTENT_PATH: $CONTENT_PATH" >> "$LOG_FILE"
echo "CATEGORY: $CATEGORY" >> "$LOG_FILE"
echo "PRIORITY: $PRIORITY" >> "$LOG_FILE"

"$HOME/scripts/helpers/notify.sh" \
  --token "$TOKEN" \
  --title "📥 $TORRENT_NAME" \
  --message "🟢 Media saved to $CONTENT_PATH"

echo "Notification sent successfully." >> "$LOG_FILE"
