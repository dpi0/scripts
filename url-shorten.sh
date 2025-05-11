#!/usr/bin/env bash

# === Config ===
ENV_FILE="$HOME/.scripts.env"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env file not found: $ENV_FILE" >&2
  exit 1
}

BASE_URL="${KISALT_URL:-https://k.ngn.tf}"
TO_SHORTEN=""
USE_CLIPBOARD=0

has_dunstify=$(command -v dunstify)
has_wl_paste=$(command -v wl-paste)
has_wl_copy=$(command -v wl-copy)

notify() {
  [[ -n "$has_dunstify" ]] && dunstify -u "$1" "$2" "$3" || echo "[$1] $2: $3" >&2
}

help() {
  echo "Usage: $0 [--shorten <url>] [--clipboard] [--base <url>] [-h|--help]"
  echo "  --shorten   URL to shorten"
  echo "  --clipboard Use clipboard content as input"
  echo "  --base      Custom shortening service base URL"
  echo "  -h, --help  Show this message"
}

# === Parse Args ===
[[ $# -eq 0 ]] && help && exit 0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --shorten)
      TO_SHORTEN="$2"
      shift 2
      ;;
    --clipboard)
      USE_CLIPBOARD=1
      shift
      ;;
    --base)
      BASE_URL="$2"
      shift 2
      ;;
    -h | --help)
      help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      help
      exit 1
      ;;
  esac
done

# If URL is empty, get the content from the clipboard
if [[ $USE_CLIPBOARD -eq 1 ]]; then
  [[ -n "$has_wl_paste" ]] && TO_SHORTEN="$($has_wl_paste)" || {
    notify critical "❌ Error" "wl-paste not found"
    exit 1
  }
fi

[[ -z "$TO_SHORTEN" ]] && notify critical "❌ Error" "No URL provided" && exit 1
# Check if clipboard contains a valid URL
[[ ! "$TO_SHORTEN" =~ ^https?:// ]] && notify critical "❌ Error" "Invalid URL: $TO_SHORTEN" && exit 1

SHORT_URL=$(curl -s "${BASE_URL}/add?url=${TO_SHORTEN}")

# Validate the shortened URL (based on expected format: example: k.ngn.tf/c9da8)
if [[ "$SHORT_URL" =~ ^[a-zA-Z0-9.-]+/[a-zA-Z0-9]+$ ]]; then
  [[ -n "$has_wl_copy" ]] && echo -n "$SHORT_URL" | $has_wl_copy
  echo "$SHORT_URL"
  notify normal "✅ Shortened: $SHORT_URL" "Original: $TO_SHORTEN"
else
  notify critical "❌ Error" "Shortening failed"
  exit 1
fi
