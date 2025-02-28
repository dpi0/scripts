#!/usr/bin/env bash

# Get the list of running containers
containers=$(docker ps --format "{{.Names}}")

# Loop through each container
for container in $containers; do
  # Inspect the container to get the mounts
  mounts=$(docker inspect -f '{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}} {{.Source}} {{.Destination}}{{println}}{{end}}{{end}}' "$container")

  # Filter out anonymous volumes and empty lines
  while IFS= read -r line; do
    if [[ $line =~ ^[a-f0-9]{64} ]] || [[ -z $line ]]; then
      continue
    fi
    echo "$line"
  done <<< "$mounts"
done
