#!/usr/bin/env bash

HOME="/home/dpi0"
ENV_FILE="$HOME/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
  echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
  exit 1
}

# Defaults from env or fallback
BOT_TOKEN="${TG_BOT_TOKEN}"
CHAT_ID="${TG_CHAT_ID}"
MESSAGE="${TG_MESSAGE:-No Message}"

usage() {
  cat << EOF
Usage: $0 -b|--bot BOT_TOKEN -c|--chat CHAT_ID [-m|--message MESSAGE]

Options:
  -b, --bot BOT_TOKEN     Telegram bot token (or TG_BOT_TOKEN)
  -c, --chat CHAT_ID      Chat ID to send message to (or TG_CHAT_ID)
  -m, --message MESSAGE   Message content (default: "No Message")

EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b | --bot)
      BOT_TOKEN="$2"
      shift 2
      ;;
    -c | --chat)
      CHAT_ID="$2"
      shift 2
      ;;
    -m | --message)
      MESSAGE="$2"
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

[[ -z $BOT_TOKEN || -z $CHAT_ID ]] && {
  echo "❌ Error: --bot and --chat are required."
  usage
}

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d text="${MESSAGE}"
