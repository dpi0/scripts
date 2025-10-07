#!/usr/bin/env bash

# batsignal passes 2 args: %s = message, %s = battery level
msg="$1"
level="$2"

USER_ENTRY=$(getent passwd 1000) || {
	echo "❌ No user with UID 1000 found. Exiting." >&2
	exit 1
}
HOME_DIR=$(cut -d: -f6 <<<"$USER_ENTRY")
ENV_FILE="$HOME_DIR/.scripts.env"
[[ -f $ENV_FILE ]] && set -a && source "$ENV_FILE" && set +a || {
	echo "❌ Env File: '$ENV_FILE' not found. Exiting." >&2
	exit 1
}

TELEGRAM_TITAN_BOT_TOKEN=${TELEGRAM_TITAN_BOT_TOKEN}
TELEGRAM_TITAN_CHAT_ID=${TELEGRAM_TITAN_CHAT_ID}

case "$msg" in
"Battery is low"*)
	emoji="⚠️"
	;;
"Battery is critical"*)
	emoji="🔥"
	;;
"Battery is full"*)
	emoji="🔋"
	;;
"Battery is discharging"*)
	emoji="🔻"
	;;
"Battery is charging"*)
	emoji="⚡"
	;;
*)
	emoji="𓈆"
	;;
esac

NOTIFICATION_TEXT="${emoji} ${msg} (${level}%)"

curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TITAN_BOT_TOKEN}/sendMessage" \
	-d chat_id="${TELEGRAM_TITAN_CHAT_ID}" \
	-d text="${NOTIFICATION_TEXT}"

echo "$(date) msg='${msg}' level='${level}' text='${NOTIFICATION_TEXT}'" >>/tmp/batsignal.log
