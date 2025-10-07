#!/usr/bin/env bash

BACKUP_DIR="$HOME/Backup/Titan/pkgs-list"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%d-%b-%Y_%H-%M-%S")

AUR_BACKUP_FILE="$BACKUP_DIR/aur-pkg-list-$TIMESTAMP"
OFFICIAL_BACKUP_FILE="$BACKUP_DIR/pkg-list-$TIMESTAMP"

pacman -Qqem >"$AUR_BACKUP_FILE"
pacman -Qqen >"$OFFICIAL_BACKUP_FILE"

# Keep only the latest 3 backups, delete older ones
# ls -1t "$BACKUP_DIR"/aur-pkg-list-* | tail -n +4 | xargs -r rm --
# ls -1t "$BACKUP_DIR"/pkg-list-* | tail -n +4 | xargs -r rm --
