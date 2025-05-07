#!/usr/bin/env bash

# -----------------
# takes a input dir, creates a .tar.gz of it, stores this in the destination directory
# custom destination directory can also be provided
# sends a notification for a successful backup
# -----------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

DEFAULT_DEST_DIR="/hdd/backup"
TIMESTAMP_FORMAT="%d-%B-%Y_%H-%M-%S"
SRC_DIR="$1"
DEST_DIR="${2:-$DEFAULT_DEST_DIR}"
ABS_SRC_DIR="$(realpath "$SRC_DIR")"
SANITIZED_PATH="${ABS_SRC_DIR//\//__}"
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
ARCHIVE_NAME="${SANITIZED_PATH}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"
RETENTION_DAYS=15 # Keep backups from the last n days

usage() {
  echo "Usage: $0 <directory_to_backup> [destination_directory]."
  echo "Default [destination_directory] is '/hdd/backup'"
  exit 1
}

[[ $# -lt 1 || $# -gt 2 ]] && usage

notify() {
  local msg="$1"
  curl -s "${NOTIFY_URL}/message?token=${NOTIFY_TOKEN}" \
    -F "title=🟠 Backing up ${SRC_DIR} to ${DEST_DIR}" \
    -F "message=$msg" > /dev/null
}

if [[ ! -d "$SRC_DIR" ]]; then
  notify "🔴 Backup failed: Invalid source directory '$SRC_DIR'"
  exit 1
fi

mkdir -p "$DEST_DIR" || {
  notify "🔴 Backup failed: Cannot create destination directory '$DEST_DIR'"
  exit 1
}

find "$DEST_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;
{
  tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$BASENAME"
} &> /dev/null

if [[ -f "$ARCHIVE_PATH" ]]; then
  notify "🟢 Backup successful: $ARCHIVE_PATH"
else
  notify "🔴 Backup failed: Archive file not created."
  exit 1
fi
