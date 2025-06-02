#!/usr/bin/env bash

ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

# Defaults from env or fallback
URL="${GOTIFY_URL}"
TOKEN="${GOTIFY_TOKEN}"
TITLE="${GOTIFY_TITLE}"
MESSAGE="${GOTIFY_MESSAGE:-No Message}"
PRIORITY="${GOTIFY_PRIORITY:-0}"

usage() {
  cat << EOF
Usage: $0 -u|--url URL -k|--token TOKEN -t|--title TITLE [-m|--message MESSAGE] [-p|--priority PRIORITY]

Options:
  -u, --url URL         Gotify server URL (or GOTIFY_URL)
  -k, --token TOKEN     Authentication token (or GOTIFY_TOKEN)
  -t, --title TITLE     Notification title (or GOTIFY_TITLE)
  -m, --message MESSAGE Message content (default: "No Message")
  -p, --priority PR     Priority level (default: 0)

EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u | --url)
      URL="$2"
      shift 2
      ;;
    -k | --token)
      TOKEN="$2"
      shift 2
      ;;
    -t | --title)
      TITLE="$2"
      shift 2
      ;;
    -m | --message)
      MESSAGE="$2"
      shift 2
      ;;
    -p | --priority)
      PRIORITY="$2"
      shift 2
      ;;
    -*)
      echo "❌ Unknown option: $1"
      usage
      ;;
    *)
      break
      ;;
  esac
done

[[ -z $URL || -z $TOKEN || -z $TITLE ]] && {
  echo "❌ Error: --url, --token, and --title are required."
  usage
}

curl -s "$URL/message?token=$TOKEN" \
  -F "title=$TITLE" \
  -F "message=$MESSAGE" \
  -F "priority=$PRIORITY"

# Debug output
# echo "📤 Notification sent with:"
# echo "  URL:      $URL"
# echo "  TOKEN:    ${TOKEN:0:4}******"
# echo "  TITLE:    $TITLE"
# echo "  MESSAGE:  $MESSAGE"
# echo "  PRIORITY: $PRIORITY"
