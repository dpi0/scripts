#!/usr/bin/env bash

HOME=/home/dpi0
ENV_FILE="$HOME/.scripts.env"

for arg in "$@"; do
  case $arg in
    --config-file=*) ENV_FILE="${arg#*=}" ;;
  esac
done

if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
fi

for arg in "$@"; do
  case $arg in
    --config-file=*) ENV_FILE="${arg#*=}" ;;
  esac
done

usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --config-file=FILE          Path to env config file (default: \$HOME/.scripts.env)
  --ssh-user=USER             SSH username (overrides SSH_USER from .env)
  --ssh-host=HOST             SSH hostname or IP (overrides SSH_HOST from .env)
  --ssh-port=PORT             SSH port (overrides SSH_PORT from .env)
  --ssh-key=FILE              Path to SSH private key (overrides SSH_KEY from .env)
  --base-dest=DIR             Local base destination for backups
  --log-dir=DIR               Directory to store log files
  --remote-dirs=DIR1,DIR2     Comma-separated list of remote directories to back up
  --excluded-dirs=DIR1,DIR2   Comma-separated list of subpaths to exclude from rsync
  --hooks-dir=DIR             Directory containing pre/post backup hook scripts
  --pre-hook=SCRIPT           Local path to a pre-backup script to run on the remote
  --post-hook=SCRIPT          Local path to a post-backup script to run on the remote
  --help                      Show this help message and exit

Example using a config file only (recommended):
  $(basename "$0") --config-file=\$HOME/backup_plans/webserver.env

Example webserver.env
SSH_USER=backup
SSH_HOST=192.168.1.100
SSH_PORT=22
SSH_KEY=/home/dpi0/.ssh/id_ed25519
BASE_DEST=/mnt/backups
LOG_DIR=/var/log/backups
REMOTE_DIRS=("/etc" "/var/www")
EXCLUDED_DIRS=("/var/www/cache")
HOOKS_DIR=/home/dpi0/scripts/hooks
PRE_BACKUP_HOOK_SCRIPT=/home/dpi0/scripts/pre_backup.sh
POST_BACKUP_HOOK_SCRIPT=/home/dpi0/scripts/post_backup.sh

Example without config file:
  $(basename "$0") \\
    --ssh-user=backup \\
    --ssh-host=192.168.1.10 \\
    --ssh-port=22 \\
    --ssh-key=\$HOME/.ssh/id_ed25519 \\
    --base-dest=/mnt/backups \\
    --log-dir=/var/log/backups \\
    --remote-dirs=/etc,/var/www \\
    --excluded-dirs=/var/www/cache,/etc/ssl/private \\
    --pre-hook=\$HOME/scripts/pre.sh \\
    --post-hook=\$HOME/scripts/post.sh

EOF
}

# Exit with usage if no arguments are passed
if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

# Step 3: Override config values with any CLI args
for arg in "$@"; do
  case $arg in
    --ssh-user=*) SSH_USER="${arg#*=}" ;;
    --ssh-host=*) SSH_HOST="${arg#*=}" ;;
    --ssh-port=*) SSH_PORT="${arg#*=}" ;;
    --ssh-key=*) SSH_KEY="${arg#*=}" ;;
    --base-dest=*) BASE_DEST="${arg#*=}" ;;
    --log-dir=*) LOG_DIR="${arg#*=}" ;;
    --remote-dirs=*) IFS=',' read -r -a REMOTE_DIRS <<< "${arg#*=}" ;;
    --excluded-dirs=*) IFS=',' read -r -a EXCLUDED_DIRS <<< "${arg#*=}" ;;
    --hooks-dir=*) HOOKS_DIR="${arg#*=}" ;;
    --pre-hook=*) PRE_BACKUP_HOOK_SCRIPT="${arg#*=}" ;;
    --post-hook=*) POST_BACKUP_HOOK_SCRIPT="${arg#*=}" ;;
    --config-file=*) ;; # Already handled above
    --help)
      usage
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

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
