#!/usr/bin/env bash

# Set the backup directory
BACKUP_DIR="$HOME/.dotfiles"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Generate a timestamp
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")

# Define filenames with timestamps
AUR_BACKUP_FILE="$BACKUP_DIR/aur-pkg-list-$TIMESTAMP"
OFFICIAL_BACKUP_FILE="$BACKUP_DIR/pkg-list-$TIMESTAMP"

# Take backups of AUR and official repo packages
pacman -Qqem > "$AUR_BACKUP_FILE"
pacman -Qqen > "$OFFICIAL_BACKUP_FILE"

# Keep only the latest 3 backups, delete older ones
ls -1t "$BACKUP_DIR"/aur-pkg-list-* | tail -n +4 | xargs -r rm --
ls -1t "$BACKUP_DIR"/pkg-list-* | tail -n +4 | xargs -r rm --

echo "Backup completed: $TIMESTAMP"
