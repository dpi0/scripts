#!/usr/bin/env bash

STATE_FILE="/tmp/gpu-screen-recorder.state"

# 0. check if gpu-screen-recorder is installed
if ! command -v gpu-screen-recorder >/dev/null; then
	dunstify -u critical "Recording Failed" "gpu-screen-recorder not found in PATH"
	exit 1
fi

# 1. check if gpu-screen-recorder already running?
if pgrep -f "gpu-screen-recorder" >/dev/null; then
	# If running, send signal to save and stop
	pkill -SIGINT -f "gpu-screen-recorder"
	rm -f "$STATE_FILE" # Remove state file when stopping
	exit 0
fi

# 2. if not running, start recording
mkdir -p "$HOME/Videos"
FILENAME="$HOME/Videos/R $(date +"%H-%M-%S_%d-%b-%y").mp4"

echo "recording" >"$STATE_FILE"

# 3. notify only if the recorder exited successfully (0) AND file exists
if gpu-screen-recorder -w portal -f 60 -a default_output -o "$FILENAME" && [ -f "$FILENAME" ]; then
	rm -f "$STATE_FILE" # Remove state file when done

	dunstify -u normal "Recording Saved" "$FILENAME" \
		--action="default,Open" \
		--action="open,Play & Copy" | while read -r action; do
		case "$action" in
		open | default)
			if command -v wl-copy >/dev/null; then
				wl-copy <"$FILENAME"
			fi
			mpv "$FILENAME" &
			;;
		esac
	done &
else
	rm -f "$STATE_FILE" # Remove state file if recording failed
fi
