#!/usr/bin/env bash
# -----------------
# takes a input dir, creates a .tar.gz of it, stores this in the destination directory
# custom destination directory can also be provided
# sends a notification for a successful backup
# tar file is named with the full path of the input directory (with slashes replaced by underscores)
# -----------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

DEFAULT_DEST_DIR="/hdd/backup"
TIMESTAMP_FORMAT="%d-%B-%Y_%H-%M-%S"
SRC_DIR="$1"
DEST_DIR="${2:-$DEFAULT_DEST_DIR}"
# Convert full path to filename-friendly format (replace slashes with underscores)
PATH_BASED_NAME=$(echo "$SRC_DIR" | sed 's/^\///; s/\//_/g')
TIMESTAMP=$(date +"$TIMESTAMP_FORMAT")
ARCHIVE_NAME="${PATH_BASED_NAME}_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"
RETENTION_DAYS=15 # Keep backups from the last n days

usage() {
  echo "Usage: $0 <directory_to_backup> [destination_directory]"
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
  tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$(basename "$SRC_DIR")"
} &> /dev/null

if [[ -f "$ARCHIVE_PATH" ]]; then
  notify "🟢 Backup successful: $ARCHIVE_PATH"
else
  notify "🔴 Backup failed: Archive file not created."
  exit 1
fi
