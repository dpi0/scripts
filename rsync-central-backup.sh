#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

# TODO: maybe create a separate user on host for backups
SSH_USER=$SSH_USER
SSH_HOST=$SSH_HOST
SSH_PORT=$SSH_PORT
SSH_KEY=$SSH_KEY
SSH_OPTS="-i $SSH_KEY -p $SSH_PORT -o StrictHostKeyChecking=accept-new"

BASE_DEST=$BASE_DEST
LOG_DIR=$LOG_DIR
LOG_FILE="$LOG_DIR/${SSH_HOST}_$(date '+%Y%m%d').log"

REMOTE_DIRS=$REMOTE_DIRS
EXCLUDED_DIRS=$EXCLUDED_DIRS

HOOKS_DIR=$HOOKS_DIR
PRE_BACKUP_HOOK_SCRIPT=$PRE_BACKUP_HOOK_SCRIPT
POST_BACKUP_HOOK_SCRIPT=$POST_BACKUP_HOOK_SCRIPT

mkdir -p "$LOG_DIR" "$BASE_DEST"

run_remote_hook() {
  local hook_label="$1"
  local hook_path="$2"

  if [[ -f "$hook_path" ]]; then
    echo "[$(date '+%F %T')] 🔧 RUNNING: $hook_label hook" | tee -a "$LOG_FILE"

    remote_tmp="/tmp/$(basename "$hook_path")"
    scp -P "$SSH_PORT" -i "$SSH_KEY" "$hook_path" "$SSH_USER@$SSH_HOST:$remote_tmp" >> "$LOG_FILE" 2>&1

    ssh $SSH_OPTS "$SSH_USER@$SSH_HOST" "bash $remote_tmp && rm -f $remote_tmp" >> "$LOG_FILE" 2>&1

    local hook_status=$?
    if [[ $hook_status -ne 0 ]]; then
      echo "[$(date '+%F %T')] 🟡 WARNING: $hook_label hook failed (exit code $hook_status)" | tee -a "$LOG_FILE"
    else
      echo "[$(date '+%F %T')] 🟢 COMPLETED: $hook_label hook" | tee -a "$LOG_FILE"
    fi
  fi
}

echo "##########################################################################" | tee -a "$LOG_FILE"
run_remote_hook "Pre-backup" "$PRE_BACKUP_HOOK_SCRIPT"

do_rsync() {
  local remote_path="$1"
  local dest_path="$BASE_DEST$remote_path"

  echo "[$(date '+%F %T')] 🔵 STARTING BACKUP: $remote_path" | tee -a "$LOG_FILE"

  # Check if rsync exists on remote host
  if ! ssh $SSH_OPTS "$SSH_USER@$SSH_HOST" "command -v rsync >/dev/null 2>&1"; then
    echo "[$(date '+%F %T')] 🔴 ERROR: 'rsync' not found on remote host $SSH_HOST. Aborting." | tee -a "$LOG_FILE" >&2
    exit 2
  fi

  mkdir -p "$dest_path"

  RSYNC_EXCLUDES=()
  for ex_path in "${EXCLUDED_DIRS[@]}"; do
    if [[ "$ex_path" == "$remote_path"* ]]; then
      rel_path="${ex_path#$remote_path/}"
      RSYNC_EXCLUDES+=("--exclude=$rel_path")
    fi
  done

  rsync -a --delete --stats \
    "${RSYNC_EXCLUDES[@]}" \
    -e "ssh $SSH_OPTS" \
    "$SSH_USER@$SSH_HOST:$remote_path/" "$dest_path/" \
    >> "$LOG_FILE" 2>&1

  local rsync_status=$?
  if [[ $rsync_status -ne 0 ]]; then
    echo "[$(date '+%F %T')] 🔴 ERROR: rsync failed for $remote_path (exit code $rsync_status)" | tee -a "$LOG_FILE" >&2
    echo "--------------------------------------------------------------------------" | tee -a "$LOG_FILE"
    exit $rsync_status
  else
    echo "[$(date '+%F %T')] 🟢 COMPLETED BACKUP: $remote_path" | tee -a "$LOG_FILE"
    echo "--------------------------------------------------------------------------" | tee -a "$LOG_FILE"
  fi
  echo >> "$LOG_FILE"
}

echo "==========================================================================" | tee -a "$LOG_FILE"
for dir in "${REMOTE_DIRS[@]}"; do
  do_rsync "$dir"
done
echo "==========================================================================" | tee -a "$LOG_FILE"

run_remote_hook "Post-backup" "$POST_BACKUP_HOOK_SCRIPT"
echo "##########################################################################" | tee -a "$LOG_FILE"

# TODO: lock down the SSH_KEY to run only certain commands for better security
# can be achived by editing the `~/.ssh/authorized_keys` file on remote
# https://webworxshop.com/centralised-backups-with-restic-and-rsync/
