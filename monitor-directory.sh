#!/usr/bin/env bash

SCRIPT_NAME=$(basename "$0")
COMMAND_TO_RUN="echo 'File change detected'"

# Function to display help menu
display_help() {
    echo "Usage: $SCRIPT_NAME [OPTIONS] DIRECTORY"
    echo "Monitor a directory for file additions or deletions and run a specific command."
    echo
    echo "Options:"
    echo "  -c, --command COMMAND   Specify the command to run when a file change is detected."
    echo "  -h, --help              Display this help menu and exit."
    echo
    echo "Example:"
    echo "  $SCRIPT_NAME -c 'echo File changed' /path/to/directory"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--command)
            COMMAND_TO_RUN="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            ;;
        *)
            if [[ -d "$1" ]]; then
                DIRECTORY="$1"
            else
                echo "Error: Invalid argument or directory not found: $1"
                display_help
            fi
            shift
            ;;
    esac
done

# Check if directory is provided
if [[ -z "$DIRECTORY" ]]; then
    echo "Error: No directory specified."
    display_help
fi

# Start monitoring the directory recursively
echo "Monitoring directory recursively: $DIRECTORY"
echo "Command to run: $COMMAND_TO_RUN"

inotifywait -m -r -e create,delete "$DIRECTORY" |
while read -r directory event file; do
    echo "Event: $event on file: $file"
    eval "$COMMAND_TO_RUN"
done
