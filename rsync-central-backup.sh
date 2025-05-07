#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || echo "🟡 Warning: .env not found at '$ENV_FILE'" >&2

SSH_HOST=$SSH_HOST
SSH_PORT=$SSH_PORT
# TODO: maybe create a separate user on host for backups
SSH_USER=$SSH_USER
SSH_KEY=$SSH_KEY
SSH_OPTS="-i $SSH_KEY -p $SSH_PORT"

BASE_DEST=$BASE_DEST
LOG_DIR=$LOG_DIR
LOG_FILE="$LOG_DIR/rsync-${SSH_HOST}_$(date '+%Y%m%d').log"

REMOTE_DIRS=$REMOTE_DIRS

mkdir -p "$LOG_DIR" "$BASE_DEST"

run_remote_hook() {
  local hook_stage="$1"
  local cmd="$2"
  echo "[$(date '+%F %T')] Running $hook_stage hook on $SSH_HOST..." | tee -a "$LOG_FILE"
  ssh $SSH_OPTS "$SSH_USER@$SSH_HOST" "bash -c '$cmd'"
}

run_remote_hook "pre-backup" 'docker stop forgejo-server'

do_rsync() {
  local remote_path="$1"
  local dest_path="$BASE_DEST$remote_path"

  echo "[$(date '+%F %T')] Starting rsync: $remote_path" | tee -a "$LOG_FILE"
  mkdir -p "$dest_path"

  rsync -aP --delete --human-readable --info=progress2 \
    -e "ssh $SSH_OPTS" \
    "$SSH_USER@$SSH_HOST:$remote_path/" "$dest_path/" \
    >> "$LOG_FILE" 2>&1

  echo "[$(date '+%F %T')] Completed: $remote_path" | tee -a "$LOG_FILE"
  echo >> "$LOG_FILE"
}

for dir in "${REMOTE_DIRS[@]}"; do
  do_rsync "$dir"
done

run_remote_hook "post-backup" 'docker start forgejo-server'

# TODO: lock down the SSH_KEY to run only certain commands for better security
# can be achived by editing the `~/.ssh/authorized_keys` file on remote
# https://webworxshop.com/centralised-backups-with-restic-and-rsync/
