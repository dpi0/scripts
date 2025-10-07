#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

GITHUB_USERNAME="$GITHUB_USERNAME"
GITHUB_REPO_NAME="$GITHUB_REPO_NAME"
LOG_FILE="$HOME/$GITHUB_REPO_NAME-$GITHUB_USERNAME-pull-sync.log"

log_info() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

log_err() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERR]  $1" >> "$LOG_FILE"
}

if docker compose -f $PATH_MKDOCS_NGINX_COMPOSE config --services | grep -q '^mkdocs-builder$'; then
  docker compose run --rm mkdocs-builder >> "$LOG_FILE" 2>&1 || {
    log_err "MkDocs build failed."
    exit 1
  }

  log_info "🟢 MkDocs site built successfully!"
else
  log_info "🔴 mkdocs-builder service not defined. Skipping MkDocs build."
fi
