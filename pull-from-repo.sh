#!/usr/bin/env bash

# Pulls the latest changes from a specified GitHub repository using a fine-grained token

USER_ENTRY=$(getent passwd 1000) || {
  echo "❌ No user with UID 1000 found. Exiting." >&2
  exit 1
}
USERNAME=$(echo "$USER_ENTRY" | cut -d: -f1)
HOME=$(echo "$USER_ENTRY" | cut -d: -f6)

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

GITHUB_USERNAME="$GITHUB_USERNAME"
GITHUB_REPO_NAME="$GITHUB_REPO_NAME"
BRANCH="main"
REPO_PATH="$REPO_PATH"
GITHUB_TOKEN="$GITHUB_PULL_REPO_TOKEN"
REMOTE_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO_NAME}.git"
LOG_FILE="$HOME/$GITHUB_REPO_NAME-$GITHUB_USERNAME-pull-sync.log"

log_info() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG_FILE"
}

log_err() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERR]  $1" >> "$LOG_FILE"
}

# Ensure the repository exists, clone if it doesn't
if [[ ! -d "$REPO_PATH/.git" ]]; then
  log_info "🟡 Repository not found. Cloning..."
  git clone --branch "$BRANCH" "$REMOTE_URL" "$REPO_PATH" || {
    log_err "🔴 Failed to clone repository."
    exit 1
  }
else
  # Safe directory addition for root
  git config --system --add safe.directory "$REPO_PATH"
fi

cd "$REPO_PATH" || {
  log_err "🔴 Repository directory missing or inaccessible."
  exit 1
}

log_info "📥 Fetching latest changes from the remote repository..."
git fetch --quiet origin >> "$LOG_FILE" 2>&1 || {
  log_err "🔴 Failed to fetch from origin."
  exit 1
}

BRANCH=$(git rev-parse --abbrev-ref HEAD)
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse "origin/$BRANCH")

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
  log_info "🔵 Changes detected. Resetting and cleaning..."

  log_info "🔁 Resetting local branch to match remote..."
  git reset --hard "origin/$BRANCH" >> "$LOG_FILE" 2>&1 || {
    log_err "🔴 Failed to reset local branch."
    exit 1
  }

  log_info "🧹Cleaning up untracked files..."
  git clean -fd >> "$LOG_FILE" 2>&1 || {
    log_err "🔴 Failed to cleanup untracked files."
    exit 1
  }

  log_info "🟢 $GITHUB_USERNAME/$GITHUB_REPO_NAME repo force-synced with remote."

  # Run the mkdocs-builder if present and log, if not do nothing.
  if docker ps -a --format '{{.Names}}' | grep -q '^mkdocs-builder$'; then
    SERVICE_NAME="mkdocs-builder"
    log_info "🧹 Removing existing $SERVICE_NAME container..."
    docker rm -f $SERVICE_NAME >> "$LOG_FILE" 2>&1 || {
      log_err "Failed to remove existing $SERVICE_NAME container."
      exit 1
    }

    log_info "🟤 Building mkdocs-material site..."

    COMPOSE_FILE="$HOME/cloudlab/services/mkdocs-nginx-serve/compose.yml"
    docker compose -f "$COMPOSE_FILE" up --no-deps --force-recreate --detach "$SERVICE_NAME" >> "$LOG_FILE" 2>&1 || {
      log_err "MkDocs build failed."
      exit 1
    }

    log_info "🟢 mkdocs-material site built successfully!"
  else
    log_info "🔴 $SERVICE_NAME service not defined. Skipping mkdocs-material build."
  fi
else
  log_info "🟡 No changes detected. Exiting."
fi
