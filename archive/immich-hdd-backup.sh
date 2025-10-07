#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
	echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
	exit 1
}

# === Global Variables ===
SRC="/hdd/Media/Immich"
EXCLUDE1="Database/"
EXCLUDE2="Uploads/thumbs/"
DEST_BASE="/space"
TIMESTAMP=$(date +"%H-%M-%S_%d-%B-%y")
DEST="$DEST_BASE/Immich-Backup-$TIMESTAMP"
LOGFILE="$HOME/.immich-backup.log"
ENABLE_LOG=false

# === Parse Args ===
if [[ "$1" == "--log" ]]; then
	ENABLE_LOG=true
fi

# === Logging Function ===
log() {
	if $ENABLE_LOG; then
		echo "$1" | tee -a "$LOGFILE"
	else
		echo "$1"
	fi
}

# === Mount Checks ===
if ! mountpoint -q /hdd; then
	log "Error: /hdd is not mounted."
	exit 1
fi

if ! mountpoint -q /space; then
	log "Error: /space is not mounted."
	exit 1
fi

# === Start Logging ===
log "=== Backup started at $(date +"%Y-%m-%d %H:%M:%S") ==="
log "Source: $SRC"
log "Destination: $DEST"

# === Backup Execution ===
if $ENABLE_LOG; then
	rsync -a --exclude="$EXCLUDE1" --exclude="$EXCLUDE2" "$SRC/" "$DEST" | tee -a "$LOGFILE"
else
	rsync -a --exclude="$EXCLUDE1" --exclude="$EXCLUDE2" "$SRC/" "$DEST"
fi

log "=== Backup finished at $(date +"%Y-%m-%d %H:%M:%S") ==="
log ""
