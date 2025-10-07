#!/usr/bin/env bash

# Pulls the latest changes from a specified GitHub repository using a fine-grained token

# Get home directory of UID 1000
USER_ENTRY=$(getent passwd 1000) || {
  echo "❌ No user with UID 1000 found. Exiting." >&2
  exit 1
}
HOME_DIR=$(cut -d: -f6 <<<"$USER_ENTRY")

# Load environment variables
ENV_FILE="$HOME_DIR/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

GH_USER="${GITHUB_USERNAME:?Missing GITHUB_USERNAME}"
GH_REPO="${GITHUB_REPO_NAME:?Missing GITHUB_REPO_NAME}"
GITHUB_TOKEN="${GITHUB_PULL_REPO_TOKEN:?Missing GITHUB_PULL_REPO_TOKEN}"
CLONE_PATH="${CLONE_PATH:?Missing CLONE_PATH}"
BRANCH="main"
REMOTE_URL="https://${GH_USER}:${GITHUB_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git"
LOG_DIR="$HOME_DIR/.local/state/pull-from-repo"
LOG_FILE="$LOG_DIR/${GH_REPO}-${GH_USER}.log"

mkdir -p "$LOG_DIR"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >>"$LOG_FILE"; }
log_err() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERR]  $1" >>"$LOG_FILE"; }

clone_repo() {
  log "⚠️ Repository not found. Cloning..."
  git clone --branch "$BRANCH" "$REMOTE_URL" "$CLONE_PATH" >>"$LOG_FILE" 2>&1 || {
    log_err "❗ Failed to clone repository."
    exit 1
  }
  git config --system --add safe.directory "$CLONE_PATH"
}

pull_latest() {
  cd "$CLONE_PATH" || {
    log_err "❗ Repo directory inaccessible."
    exit 1
  }

  log "Fetching latest changes from remote..."
  git fetch --quiet origin >>"$LOG_FILE" 2>&1 || {
    log_err "❗ Failed to fetch from origin."
    exit 1
  }

  local_branch=$(git rev-parse --abbrev-ref HEAD)
  local_hash=$(git rev-parse HEAD)
  remote_hash=$(git rev-parse "origin/$local_branch")

  if [[ "$local_hash" != "$remote_hash" ]]; then
    log "🔵 Changes detected. Resetting and cleaning..."
    git reset --hard "origin/$local_branch" >>"$LOG_FILE" 2>&1 || {
      log_err "❗ Failed to reset branch."
      exit 1
    }
    git clean -fd >>"$LOG_FILE" 2>&1 || {
      log_err "❗ Failed to clean untracked files."
      exit 1
    }
    log "🟢 $GH_USER/$GH_REPO repo force-synced with remote."
  else
    log "⚠️ No changes detected. Exiting."
  fi
}

# Main execution
[[ -d "$CLONE_PATH/.git" ]] || clone_repo
pull_latest
