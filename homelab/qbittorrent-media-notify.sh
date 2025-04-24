#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

TORRENT_NAME=${1:-"Unknown Torrent"}
CATEGORY=${2:-"Unknown Category"}
CONTENT_PATH=${3:-"Unknown Content Path"}
PRIORITY=5

notify() {
  curl -s "${NOTIFY_URL}/message?token=${QB_NOTIFY_TOKEN}" \
    -F "title=📥 $TORRENT_NAME" \
    -F "message='🟢 Media saved to $CONTENT_PATH'" \
    -F "priority=$PRIORITY"
}

echo "----------------------------------------" >> "$QB_LOG_FILE_PATH"
echo "Timestamp: $(date)" >> "$QB_LOG_FILE_PATH"
echo "TORRENT_NAME: $TORRENT_NAME" >> "$QB_LOG_FILE_PATH"
echo "CONTENT_PATH: $CONTENT_PATH" >> "$QB_LOG_FILE_PATH"
echo "CATEGORY: $CATEGORY" >> "$QB_LOG_FILE_PATH"
echo "PRIORITY: $PRIORITY" >> "$QB_LOG_FILE_PATH"

notify

echo "Notification sent successfully." >> "$QB_LOG_FILE_PATH"
