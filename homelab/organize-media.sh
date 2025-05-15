#!/usr/bin/env bash

# Global variables
LOG_FILE="$HOME/.organize_media.log"
REQUIRED_TOOLS=("fd")

# Month name mapping
declare -A MONTH_NAMES=(
  ["01"]="January"
  ["02"]="February"
  ["03"]="March"
  ["04"]="April"
  ["05"]="May"
  ["06"]="June"
  ["07"]="July"
  ["08"]="August"
  ["09"]="September"
  ["10"]="October"
  ["11"]="November"
  ["12"]="December"
)

# Function to log messages
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
  local log_message="[$timestamp] [$1] $2"
  if [ "$1" = "FAILED" ]; then
    echo -e "\e[31m$log_message\e[0m" | tee -a "$LOG_FILE"
  else
    echo "$log_message" | tee -a "$LOG_FILE"
  fi
}

# Function to check required tools
check_required_tools() {
  local missing_tools=()
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      missing_tools+=("$tool")
    fi
  done

  if [ ${#missing_tools[@]} -ne 0 ]; then
    log "ERROR" "The following required tools are missing: ${missing_tools[*]}"
    exit 1
  fi
}

# Function to extract date from filename with YYYYMMDD pattern
extract_date_from_filename() {
  local filename="$1"
  if [[ $filename =~ ([0-9]{4})([0-9]{2})([0-9]{2}) ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
  else
    echo ""
  fi
}

# Function to extract date from filename with YYYY-MM-DD or YYYY_MM_DD pattern
extract_date_from_filename_hyphen_or_underscore() {
  local filename="$1"
  if [[ $filename =~ ([0-9]{4})[-_]([0-9]{2})[-_]([0-9]{2}) ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
  else
    echo ""
  fi
}

# Function to organize files
organize_files() {
  local input_dir="$1"
  local output_dir="$2"
  local copy_only="$3"

  # Use fd to find all supported file formats in the input directory and match the full file path
  fd --full-path "$input_dir" -e jpg -e jpeg -e JPG -e JPEG -e png -e PNG -e gif -e GIF -e mp4 -e mov -e MP4 -e MOV | while read -r file; do
    # Extract the filename without the extension
    filename=$(basename "$file")

    # Extract the date from the filename using the enabled patterns
    date_info=$(extract_date_from_filename "$filename")
    if [ -z "$date_info" ]; then
      date_info=$(extract_date_from_filename_hyphen_or_underscore "$filename")
    fi

    if [ -z "$date_info" ]; then
      log "FAILED" "Filename does not match any enabled pattern: $filename"
      continue
    fi

    # Split date_info into year, month, and day
    read -r YEAR MONTH DAY <<< "$date_info"

    # Get the month name
    MONTH_NAME=${MONTH_NAMES[$MONTH]}

    # Create the directory if it doesn't exist
    DEST_DIR="$output_dir/$YEAR/$MONTH-$MONTH_NAME"
    mkdir -p "$DEST_DIR"

    # Move or copy the file to the appropriate directory
    if [ "$copy_only" = true ]; then
      cp "$file" "$DEST_DIR/"
      log "COPIED" "$file ---> $DEST_DIR"
    else
      mv "$file" "$DEST_DIR/"
      log "MOVED" "$file ---> $DEST_DIR"
    fi
  done
}

# Function to display help menu
display_help() {
  local SCRIPT_NAME=$(basename "$0")
  echo "Usage: $SCRIPT_NAME [OPTIONS] <input_directory>"
  echo "Organize media files in the input directory based on date patterns."
  echo ""
  echo "Options:"
  echo "  --copy              Copy files instead of moving them. Default is move."
  echo "  --output-dir <dir>  Specify the output directory. Default is <input_directory>_Organized."
  echo ""
  echo "Examples:"
  echo "  $SCRIPT_NAME /hdd/Media/Photos/Vacation"
  echo "      - Default behavior: Move files to /hdd/Media/Photos/Vacation_Organized"
  echo "  $SCRIPT_NAME /hdd/Media/Photos/Vacation --copy"
  echo "      - Copy files to /hdd/Media/Photos/Vacation_Organized"
  echo "  $SCRIPT_NAME /hdd/Media/Photos/Vacation --output-dir /hdd/Media/NEW/TRY"
  echo "      - Move files to the specified output directory /hdd/Media/NEW/TRY"
  echo "  $SCRIPT_NAME --copy /hdd/Media/Photos/Vacation --output-dir /hdd/Media/NEW/TRY"
  echo "      - Copy files to the specified output directory /hdd/Media/NEW/TRY"
  exit 0
}

# Main function
main() {
  # Default values
  local copy_only=false
  local output_dir=""

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --copy) copy_only=true ;;
      --output-dir)
        output_dir="$2"
        shift
        ;;
      --help) display_help ;;
      *) INPUT_DIR="$1" ;;
    esac
    shift
  done

  # Check if input directory is provided
  if [ -z "$INPUT_DIR" ]; then
    log "ERROR" "Input directory is required. Use --help for usage information."
    exit 1
  fi

  # Set default output directory if not provided
  if [ -z "$output_dir" ]; then
    OUTPUT_DIR="${INPUT_DIR}_Organized"
  else
    OUTPUT_DIR="$output_dir"
  fi

  # Check required tools
  check_required_tools

  # Organize files
  organize_files "$INPUT_DIR" "$OUTPUT_DIR" "$copy_only"

  # Log the auto-created output directory
  log "INFO" "Auto-created output directory: $OUTPUT_DIR"
}

# Run the main function
main "$@"
