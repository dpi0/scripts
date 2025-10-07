#!/usr/bin/env bash

# Default output directory
OUTPUT_DIR="$HOME/Downloads/Videos"

# Override output directory if provided as argument
if [ "$1" ]; then
	OUTPUT_DIR="$1"
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check for required dependencies
check_dependency() {
	if ! command -v "$1" &>/dev/null; then
		echo "Error: $1 is not installed or not in PATH"
		exit 1
	fi
}

check_dependency "wl-paste"
check_dependency "yt-dlp"

# Check for notification command
NOTIFY_CMD=""
if command -v dunstify &>/dev/null; then
	NOTIFY_CMD="dunstify"
elif command -v notify-send &>/dev/null; then
	NOTIFY_CMD="notify-send"
else
	echo "Error: Neither dunstify nor notify-send is available"
	exit 1
fi

# Get URL from clipboard
URL=$(wl-paste)

$NOTIFY_CMD "Validating Clipboard Item..." "$URL"

if [ -z "$URL" ]; then
	$NOTIFY_CMD "Download Error" "No URL found in clipboard"
	exit 1
fi

# Validate URL format
if ! [[ "$URL" =~ ^https?:// ]]; then
	$NOTIFY_CMD "Download Error" "Invalid URL format (must start with http:// or https://)"
	exit 1
fi

# Validate URL with yt-dlp
if ! yt-dlp --no-download --quiet "$URL" 2>/dev/null; then
	$NOTIFY_CMD "Download Error" "URL not supported by yt-dlp: $URL"
	exit 1
fi

# Notify download start
$NOTIFY_CMD "Download Started" "$URL"

# Download with yt-dlp
if yt-dlp --newline \
	-o "$OUTPUT_DIR/%(title)s.%(ext)s" \
	--embed-subs \
	--write-sub \
	--sub-lang en \
	--embed-thumbnail \
	--merge-output-format mp4 \
	--format bestvideo+bestaudio \
	--ignore-config \
	--add-metadata \
	"$URL" 2>/dev/null; then

	# Get the downloaded file name
	FILENAME=$(yt-dlp --get-filename -o "%(title)s.%(ext)s" "$URL" 2>/dev/null | sed 's/\.[^.]*$/.mp4/')
	FILEPATH="$OUTPUT_DIR/$FILENAME"

	$NOTIFY_CMD "Download Complete" "Saved to: $FILEPATH"
else
	$NOTIFY_CMD -u critical "Download Error" "Failed to download: $URL"
	exit 1
fi
