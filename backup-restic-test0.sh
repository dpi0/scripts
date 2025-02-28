#!/bin/bash

# RID=`uuidgen`
BACKUP_SOURCE="$HOME/dev/go"
RESTIC_PASSWORD_FILE="$HOME/.password_restic"
RESTIC_REPOSITORY="/hdd/backup/test_go_local"
RESTIC_REPO_LOCATION_AND_PASSWORD="-r $RESTIC_REPOSITORY --password-file $RESTIC_PASSWORD_FILE"
LOG_FILE="$HOME/.backup.log"
TEMP_LOG_FILE="$HOME/.backup_temp.log"
WEBHOOK_URL="https://healthchecks.dpi0.cloud/ping/610fd78b-7a64-4a20-a4fd-5dfdb5d803f7"
KEEP_OPTIONS="--keep-last 6 --keep-hourly 1 --keep-daily 8 --keep-weekly 3 --keep-monthly 1"
CURL_OPTIONS="-fsS -m 10 --retry 5 --data-raw"
BACKUP_OPTIONS="--skip-if-unchanged --tag=test"
PRUNE_OPTIONS="--prune --cleanup-cache"
# EXCLUDE_OPTIONS="--exclude '**/node_modules' \
#   --exclude $HOME/.local/share/Trash \
#   --exclude $HOME/.local/share/pnpm \
#   --exclude $HOME/Virtual_Machines \
#   --exclude $HOME/ISOs \
#   --exclude $HOME/.rustup \
#   --exclude $HOME/.cache \
#   --exclude $HOME/go \
#   --exclude $HOME/.cargo \
#   --exclude $HOME/.npm"

HAS_FAILED=0

touch $LOG_FILE
touch $TEMP_LOG_FILE

# Function to log messages
log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE" >> "$TEMP_LOG_FILE"
}

# Function to run a command and capture its output to the log file
run_command() {
        local CMD="$1"
        echo "" > "$TEMP_LOG_FILE"  # Clear temp log file
        log "Running: $CMD"
        $CMD >> "$TEMP_LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
                HAS_FAILED=1
                log "Command failed: $CMD"
                log "Error details: $(tail -n 10 "$TEMP_LOG_FILE")"  # Log last 10 lines of error output
                return 1
        fi
        log "Command succeeded: $CMD"
        return 0
}

# Function to send webhook
send_webhook() {
        local STATUS="$1"
        local OUTPUT=$(cat "$TEMP_LOG_FILE")
        curl $CURL_OPTIONS "$OUTPUT" "$WEBHOOK_URL/$STATUS"
}

# Send start ping
send_webhook "start"

# Perform Restic unlock
if ! run_command "restic $RESITC_REPO_LOCATION_AND_PASSWORD unlock"; then
        send_webhook "$HAS_FAILED"
        exit 1
fi

# Perform Restic backup
if ! run_command "restic $RESITC_REPO_LOCATION_AND_PASSWORD backup $BACKUP_OPTIONS $EXCLUDE_OPTIONS $BACKUP_SOURCE"; then
        send_webhook "$HAS_FAILED"
        exit 1
fi

# Perform Restic forget
if ! run_command "restic $RESITC_REPO_LOCATION_AND_PASSWORD forget $KEEP_OPTIONS $PRUNE_OPTIONS"; then
        send_webhook "$HAS_FAILED"
        exit 1
fi

# Send final status
send_webhook "$HAS_FAILED"

# Send log content to Healthchecks.io /log endpoint
send_webhook "log"
