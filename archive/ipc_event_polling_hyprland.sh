#!/bin/bash

# https://github.com/Alexays/Waybar/issues/672#issuecomment-2198432615
# https://red.ngn.tf/r/hyprland/comments/17ywmtm/how_to_let_me_know_that_im_in_fullscreen/kjuk87x/?context=3#kjuk87x

# INFO: The Socket Connection:
# The socat command connects to Hyprland's event socket (a special file that Hyprland writes events to).
# Think of it like a live news feed - whenever something happens in Hyprland (window opens, workspace changes, etc.),
# it sends a message through this socket.
# Why This Approach:
# Instead of constantly polling "is window fullscreen?" every second (wasteful),
# this script waits for Hyprland to tell it when something relevant happened, then checks the status.
# It's event-driven rather than polling-based.

# These lines check that required environment variables are set
# If they're not set, the script will exit with an error message
: "${XDG_RUNTIME_DIR:?Environment variable XDG_RUNTIME_DIR not set}"
: "${HYPRLAND_INSTANCE_SIGNATURE:?Environment variable HYPRLAND_INSTANCE_SIGNATURE not set}"

# This function processes incoming events from Hyprland
handle() {
	case "$1" in
	# If the event starts with any of these patterns, call update_active_clients
	workspace* | focusedmon* | openwindow* | closewindow* | movewindow* | fullscreen*)
		update_active_clients
		;;
		# If it's any other event, do nothing (the ;; ends this case)
	esac
}

# This function checks if the currently active window is fullscreen
update_active_clients() {
	active_window=$(hyprctl activewindow -j)

	# Extract fullscreen status from the JSON
	is_fullscreen=$(echo "$active_window" | jq -r .fullscreen)

	# Extract initial class from the JSON
	initial_class=$(echo "$active_window" | jq -r .initialClass)

	# echo "$is_fullscreen"

	if [[ "$is_fullscreen" == "1" ]]; then
		echo "Fullscreen   " >&2
	fi

	# if [ "$is_fullscreen" = 1 ]; then
	# 	echo "fullscreen"
	# else
	# 	echo ""
	# fi
}

# Run the check once when the script starts
update_active_clients

# This is the main event loop that listens to Hyprland events
# socat creates a connection to Hyprland's event socket
# -U = use UNIX domain sockets
# UNIX-CONNECT = connect to a UNIX socket at the given path
# The path is built from environment variables: /run/user/1000/hypr/SIGNATURE/.socket2.sock
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while IFS= read -r line; do
	# For each line of output from socat (each event from Hyprland):
	# IFS= prevents word splitting, -r prevents backslash interpretation
	# Call the handle function with the event line as an argument
	handle "$line"
done
