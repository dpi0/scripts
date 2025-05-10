#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

BASE_URL="${KISALT_URL:-https://k.ngn.tf}"
TO_SHORTEN_URL=""

show_help() {
  echo "Usage: $0 [--base <base_url>] [--shorten <url>] [-h|--help]"
  echo
  echo "Options:"
  echo "  --base     Base shortening service URL (default: https://k.ngn.tf)"
  echo "  --shorten  URL to shorten (if omitted, uses clipboard via wl-paste)"
  echo "  -h, --help Show this help message"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE_URL="$2"
      shift 2
      ;;
    --shorten)
      TO_SHORTEN_URL="$2"
      shift 2
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# If URL is empty, get the content from the clipboard
if [[ -z "$TO_SHORTEN_URL" ]]; then
  TO_SHORTEN_URL="$(/usr/bin/wl-paste)"
fi

# Check if clipboard contains a valid URL
if [[ ! "$TO_SHORTEN_URL" =~ ^https?:// ]]; then
  dunstify -u critical "❌ Error" "Clipboard does not contain a valid URL."
  exit 1
fi

SHORTENED_URL="$(curl -s "${BASE_URL}/add?url=${TO_SHORTEN_URL}")"

# Validate the shortened URL (based on expected format: example: k.ngn.tf/c9da8)
if [[ "$SHORTENED_URL" =~ ^[a-zA-Z0-9.-]+/[a-zA-Z0-9]+$ ]]; then
  echo -n "$SHORTENED_URL" | /usr/bin/wl-copy
  dunstify -u normal "✅ URL Copied to Clipboard" "$SHORTENED_URL"
else
  dunstify -u critical "❌ Error" "Failed to retrieve shortened URL."
fi
