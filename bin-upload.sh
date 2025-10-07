#!/usr/bin/env bash

# https://github.com/wantguns/bin/blob/master/contrib/cli/client

# Change the url accordingly
URL="https://x.i0w.xyz"

FILEPATH="$1"
FILENAME=$(basename -- "$FILEPATH")
EXTENSION="${FILENAME##*.}"

# FIX: Added quotes around FILEPATH
# RESPONSE=$(curl --data-binary @${FILEPATH:-/dev/stdin} --url $URL)
RESPONSE=$(curl --data-binary "@${FILEPATH:-/dev/stdin}" --url "$URL")
PASTELINK="$URL$RESPONSE"

[ -z "$EXTENSION" ] &&
	echo "$PASTELINK" ||
	echo "$PASTELINK.$EXTENSION"
