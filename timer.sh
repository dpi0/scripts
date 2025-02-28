#!/usr/bin/env bash

# Function to display remaining time with rainbow colors
display_time() {
  local SECONDS_LEFT=$1
  local MINUTES=$((SECONDS_LEFT / 60))
  local SECONDS=$((SECONDS_LEFT % 60))
  local COLORS=("\e[31m" "\e[33m" "\e[32m" "\e[36m" "\e[34m" "\e[35m" "\e[37m")
  local COLOR_INDEX=$((SECONDS_LEFT % ${#COLORS[@]}))
  local COLOR=${COLORS[$COLOR_INDEX]}
  printf "\r${COLOR}󱎫 || Remaining: %02dm %02ds ||\e[0m" "$MINUTES" "$SECONDS"
}

# Convert input time to seconds
convert_time_to_seconds() {
  local TIME=$1
  if [[ $TIME =~ ^([0-9]+)m$ ]]; then
    echo $(( ${BASH_REMATCH[1]} * 60 ))
  elif [[ $TIME =~ ^([0-9]+)s$ ]]; then
    echo ${BASH_REMATCH[1]}
  else
    echo 0
  fi
}

# Input validation
if [ $# -lt 1 ]; then
  echo "Usage: $0 <time> [task]"
  echo "Examples:"
  echo "  $0 10m Task name"
  echo "  $0 30s"
  echo "  $0 1h 30m Task name"
  echo ""
  echo "Time format:"
  echo "  <number>m for minutes"
  echo "  <number>s for seconds"
  echo "  <number>h <number>m for hours and minutes"
  exit 1
fi


# Get the duration and task from arguments
DURATION=$(convert_time_to_seconds $1)
TASK=${2:-"No task"}

# Check if the duration is valid
if [ $DURATION -le 0 ]; then
  echo "Invalid time format. Use <number>m for minutes or <number>s for seconds."
  exit 1
fi

# Print the start time
START_TIME=$(date +"%H:%M:%S")
echo -e "Started on $START_TIME\n"

# Countdown loop
for ((i=DURATION; i>=0; i--)); do
  display_time "$i"
  sleep 1
done

# Clear the line after the timer is done
echo -ne "\r\033[K"

# Print the end time
END_TIME=$(date +"%H:%M:%S")
echo -e "Ended on $END_TIME\n"

# Send notifications
notify-send -u critical "Time's Up! $1" "$TASK"

# ntfy publish \
#     --title "Time's Up! $1" \
#     --tags computer,boom \
#     --quiet \
#     --priority default \
#     "$NTFY_MESSAGE_TOPIC" \
#     "$TASK"
