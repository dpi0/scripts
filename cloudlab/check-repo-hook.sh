#!/usr/bin/env bash

# Get home directory of UID 1000
USER_ENTRY=$(getent passwd 1000) || {
	echo "❌ No user with UID 1000 found. Exiting." >&2
	exit 1
}
HOME_DIR=$(cut -d: -f6 <<<"$USER_ENTRY")

REPO_DIR="$REPO_DIR"
HASH_FILE="/tmp/last_known_git_hash"
LOG_DIR="$HOME_DIR/.local/state/check-repo-hook"
LOG_FILE="$LOG_DIR/run.log"

mkdir -p "$LOG_DIR"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >>"$LOG_FILE"; }
log_err() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERR]  $1" >>"$LOG_FILE"; }

# Store old hash
OLD_HASH=$(cat "$HASH_FILE" 2>/dev/null || echo "")

# Run pull script
"$HOME_DIR"/scripts/pull-from-repo.sh

# Get new hash
cd "$REPO_DIR" || exit 1
NEW_HASH=$(git rev-parse HEAD)

# Compare and trigger
if [[ "$NEW_HASH" != "$OLD_HASH" ]]; then
	service_name="mkdocs-builder"
	log "🟤 Building mkdocs-material site..."
	docker restart "$service_name" >>"$LOG_FILE" 2>&1 || {
		log_err "❗ Site build failed. Exiting..."
		exit 1
	}
	log "🟢 mkdocs-material site built successfully!"
fi
