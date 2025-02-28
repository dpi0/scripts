#!/usr/bin/env bash

# Default password file path
DEFAULT_PASSWORD_FILE="$HOME/.password_restic"

# Healthchecks URL
HEALTHCHECKS_URL="https://healthchecks.dpi0.cloud/ping/3d55a45e-d7ea-4bd7-9dec-6110de806301"

# Gotify URL and token
GOTIFY_URL="https://notify.dpi0.cloud"
GOTIFY_TOKEN="ATKEPZpu0QE1Yjs"

# Log file path
LOG_FILE_PATH="$HOME/.backup.log"

# Initialize variables
SOURCE_DIR=""
REPO_NAME=""
PASSWORD_FILE=""
EXCLUDE_OPTIONS=()
SCRIPT_NAME=$(basename "$0")
NOTIFY_GOTIFY=false
REPO_TYPE=""

# Function to log messages
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
    local log_message="[$timestamp] [$1] $2 $3"
    echo "$log_message" | tee -a "$LOG_FILE_PATH"
}

# Function to send healthchecks.io signal
send_healthchecks_ping() {
    local signal="$1"
    curl -fsS -m 10 --retry 5 -o /dev/null "$HEALTHCHECKS_URL/$signal"
}

# Function to send Gotify notification
send_gotify_notification() {
    local title="$1"
    local message="$2"
    curl "$GOTIFY_URL/message?token=$GOTIFY_TOKEN" -F "title=$title" -F "message=$message"
}

# Function to handle errors
handle_error() {
    log "ERROR" "$1"
    send_healthchecks_ping "fail"
    exit 1
}

# Function to check mandatory arguments
check_mandatory_args() {
    if [[ -z "$SOURCE_DIR" || -z "$REPO_NAME" || -z "$REPO_TYPE" ]]; then
        handle_error "--input, --output, and --type options are mandatory."
    fi
}

# Function to initialize repository
initialize_repo() {
    if [[ "$REPO_TYPE" == "local" ]]; then
        if [[ ! -d "$RESTIC_REPOSITORY" ]]; then
            log "INFO" "Checking if local repo exists"
            log "INFO" "Initializing local repo"
            restic init -r "$RESTIC_REPOSITORY" || handle_error "Failed to initialize repository."
        else
            log "INFO" "Local repo already present, continuing with $RESTIC_REPOSITORY"
        fi
    elif [[ "$REPO_TYPE" == "cloud" ]]; then
        log "INFO" "Checking if cloud repo exists"
        if ! restic snapshots -r "$RESTIC_REPOSITORY" > /dev/null 2>&1; then
            log "INFO" "Initializing cloud repo"
            restic init -r "$RESTIC_REPOSITORY" || handle_error "Failed to initialize repository."
        else
            log "INFO" "Cloud repo already present, continuing with $RESTIC_REPOSITORY"
        fi
    else
        handle_error "Invalid repository type: $REPO_TYPE"
    fi
}

# Function to perform restic operations
restic_operation() {
    local operation="$1"
    local options="$2"
    log "$operation" "$SOURCE_DIR" "$RESTIC_REPOSITORY"
    restic "$operation" $options > /dev/null 2>&1 || handle_error "$operation failed."
}

# Function to check required tools
check_tools() {
    for tool in "restic" "curl"; do
        command -v "$tool" &> /dev/null || handle_error "Required tool '$tool' is missing."
    done
}

# Function to display help menu
show_help() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo "Options:"
    echo "  -h, --help              Show this help menu"
    echo "  -i, --input <dir>       Directory to backup (mandatory)"
    echo "  -o, --output <repo>     Restic repository name (mandatory)"
    echo "  -p, --password-file <file>  Path to the password file (optional, default: $DEFAULT_PASSWORD_FILE)"
    echo "  --exclude <pattern>     Exclude pattern for restic backup (optional, multiple allowed)"
    echo "  --notify-gotify         Enable Gotify notifications"
    echo "  --type <local|cloud>    Type of repository (mandatory)"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -i|--input) SOURCE_DIR="$2"; shift ;;
        -o|--output) REPO_NAME="$2"; shift ;;
        -p|--password-file) PASSWORD_FILE="$2"; shift ;;
        --exclude) EXCLUDE_OPTIONS+=("--exclude" "$2"); shift ;;
        --notify-gotify) NOTIFY_GOTIFY=true ;;
        --type) REPO_TYPE="$2"; shift ;;
        *) handle_error "Unknown option: $1" ;;
    esac
    shift
done

# Check mandatory arguments
check_mandatory_args

# Set default password file if not provided
PASSWORD_FILE="${PASSWORD_FILE:-$DEFAULT_PASSWORD_FILE}"

# Export environment variables
export RESTIC_REPOSITORY="$REPO_NAME"
export RESTIC_PASSWORD_FILE="$PASSWORD_FILE"

# Check required tools
check_tools

# Create the repo if it doesn't exist
initialize_repo

# Log file setup
touch "$LOG_FILE_PATH"

# Check if HEALTHCHECKS_URL is set
if [[ -z "$HEALTHCHECKS_URL" ]]; then
    handle_error "HEALTHCHECKS_URL is not set. Please set it properly."
fi

# Healthchecks.io start
send_healthchecks_ping "start"

# Perform restic operations
log "INFO" "Performing backup of $SOURCE_DIR"
restic_operation "unlock"
restic_operation "backup" "--skip-if-unchanged --tag=test ${EXCLUDE_OPTIONS[*]} $SOURCE_DIR"
log "INFO" "Backup complete"

# Send Gotify notification for successful backup if --notify-gotify is used
if $NOTIFY_GOTIFY; then
    send_gotify_notification "Backup Successful" "Backup of $SOURCE_DIR completed successfully."
fi

log "INFO" "Pruning and forgetting snapshots"
log "INFO" "Keeping the last 5 snapshots, daily snapshots for the last 7 days, weekly snapshots for the last 4 weeks, and monthly snapshots for the last 6 months"
restic_operation "forget" "--keep-last 5 --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune --cleanup-cache"
log "INFO" "Pruning complete"

# Send Gotify notification for successful pruning if --notify-gotify is used
if $NOTIFY_GOTIFY; then
    send_gotify_notification "Pruning Successful" "Pruning of $RESTIC_REPOSITORY completed successfully."
fi

# Healthchecks.io success
send_healthchecks_ping

exit 0
