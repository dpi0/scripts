#!/usr/bin/env bash

set -euo pipefail

container="backrest"
backup_script="/home/dpi0/scripts/homelab/backup-dir-archive.sh"
input_dir="/home/dpi0/homelab-data/backrest"
output_dir="/hdd/backup/backrest-backup"
compose_dir="/home/dpi0/homelab/backrest"
compose_file="compose.yml"
keep_last=10

# only restart if container was already running.
was_running=false

if docker ps --format '{{.Names}}' | grep -Eqx "^${container}$"; then
  was_running=true
  docker stop "$container"
fi

"$backup_script" --input "$input_dir" --output "$output_dir" --keep-last "$keep_last"

# only start if it was already running
if [ "$was_running" = true ]; then
  docker start "$container" > /dev/null 2>&1 ||
    docker compose -f "$compose_dir/$compose_file" up "$container" --detach || true
fi
