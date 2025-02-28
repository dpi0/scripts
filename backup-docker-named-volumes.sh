#!/usr/bin/env bash

# Global variables
LIST_DOCKER_VOLUMES_SCRIPT_PATH="list-docker-named-volumes-with-path.sh"
BACKUP_DIR_ONLY=false
BACKUP_ROOT="$HOME/backup_named_vol"
DOCKER_RUN_CMD="docker run --rm"

# Check if the --backup-dir-only flag is specified
if [[ "$1" == "--backup-dir-only" ]]; then
    BACKUP_DIR_ONLY=true
fi

# Function to perform the backup
perform_backup() {
    local volume_to_backup=$1
    local mount_point_in_container=$2
    local backup_location="$BACKUP_ROOT/$volume_to_backup"

    mkdir -p "$backup_location"

    if $BACKUP_DIR_ONLY; then
        $DOCKER_RUN_CMD \
        --mount source="$volume_to_backup",target="$mount_point_in_container" \
        -v "$backup_location:/backup" \
        busybox \
        cp -r "$mount_point_in_container" "/backup/"
    else
        $DOCKER_RUN_CMD \
        --mount source="$volume_to_backup",target="$mount_point_in_container" \
        -v "$backup_location:/backup" \
        busybox \
        tar -czvf "/backup/$volume_to_backup.tar.gz" "$mount_point_in_container"
    fi
}

# Read the output of the script and process each line
while IFS= read -r line; do
    IFS=' ' read -r VOLUME_TO_BACKUP _ MOUNT_POINT_IN_CONTAINER <<< "$line"
    perform_backup "$VOLUME_TO_BACKUP" "$MOUNT_POINT_IN_CONTAINER"
done < <("$LIST_DOCKER_VOLUMES_SCRIPT_PATH")
