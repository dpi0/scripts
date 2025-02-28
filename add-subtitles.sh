#!/bin/bash

# Script name
SCRIPT_NAME=$(basename "$0")

# Global variables
INPUT_VIDEO=""
SUBTITLE_FILE=""
DIRECTORY=""
AUTO_FIND_SUB=false
KEEP_ORIGINAL_VIDEO=false
DIR_NAME=""
DIR_SEARCH_PATH=""
ONLY_RARBG_VXT=false

# Notification variables
URL="https://notify.dpi0.cloud/message"
TOKEN="AAoS.gnmxMp4Bmc"

# Function to display usage
usage() {
    echo "Usage: $SCRIPT_NAME --directory <directory_path> --auto-find-sub [--keep-original-video-file]"
    echo "       $SCRIPT_NAME --video <original_video_path> --auto-find-sub [--keep-original-video-file]"
    echo "       $SCRIPT_NAME --video <original_video_path> --sub <subtitle_path> [--keep-original-video-file]"
    echo "       $SCRIPT_NAME --dir-name <directory_name> --dir-search-path <search_path> --auto-find-sub"
    echo "       $SCRIPT_NAME --only-rarbg-vxt"
    echo ""
    echo "Options:"
    echo "  --directory <directory_path>   Path to the directory containing the video file."
    echo "  --video <original_video_path>  Path to the original video file."
    echo "  --sub <subtitle_path>          Path to the subtitle file."
    echo "  --auto-find-sub                Automatically find the subtitle file in the directory."
    echo "  --keep-original-video-file     Keep the original video file and create a new output file."
    echo "  --dir-name <directory_name>    Name of the directory to search for."
    echo "  --dir-search-path <search_path> Path to search for the directory."
    echo "  --only-rarbg-vxt               Ensure the directory name contains 'RARBG' or 'VXT'."
    echo "  -h, --help                     Display this help menu."
    exit 1
}

# Function to display messages
msg() {
    echo "[INFO] $1"
}

# Function to handle errors
handle_error() {
    local error_message="$1"
    local error_title="Error"
    local error_details=""
    local priority=10

    case "$error_message" in
        "No video file found in directory"*)
            error_title="No Video File Found"
            error_details="Directory: $(dirname "$INPUT_VIDEO")"
            ;;
        "More than one video file found in directory"*)
            error_title="Multiple Video Files Found"
            error_details="Directory: $(dirname "$INPUT_VIDEO")"
            ;;
        "No subtitle file found in directory"*)
            error_title="No Subtitle File Found"
            error_details="Directory: $(dirname "$INPUT_VIDEO")"
            ;;
        "No directory named"*)
            error_title="Directory Not Found"
            error_details="Search Path: $DIR_SEARCH_PATH"
            ;;
        "Failed to embed subtitles"*)
            error_title="Subtitle Embedding Failed"
            error_details="Video: $INPUT_VIDEO"
            ;;
        "Directory name does not contain 'RARBG' or 'VXT'"*)
            error_title="Invalid Directory Name"
            error_details="Directory: $DIRECTORY"
            ;;
        *)
            error_title="Unknown Error"
            error_details="Details: $error_message"
            ;;
    esac

    echo "[ERROR] $error_message"
    send_notification "$error_title" "$error_details" "$priority"
    exit 1
}

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local priority="$3"

    curl -s -o /dev/null -X POST "$URL?token=$TOKEN" \
        -F "title=$title" \
        -F "message=$message" \
        -F "priority=$priority"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --directory) DIRECTORY="$2"; shift ;;
            --video) INPUT_VIDEO="$2"; shift ;;
            --sub) SUBTITLE_FILE="$2"; shift ;;
            --auto-find-sub) AUTO_FIND_SUB=true ;;
            --keep-original-video-file) KEEP_ORIGINAL_VIDEO=true ;;
            --dir-name) DIR_NAME="$2"; shift ;;
            --dir-search-path) DIR_SEARCH_PATH="$2"; shift ;;
            --only-rarbg-vxt) ONLY_RARBG_VXT=true ;;
            -h|--help) usage ;;
            *) handle_error "Unknown parameter passed: $1" ;;
        esac
        shift
    done
}

# Function to find the single video file in the directory
find_video_file() {
    local dir="$1"
    local video_files
    video_files=$(fd -e mp4 -e avi -e mkv . "$dir")
    
    if [ -z "$video_files" ]; then
        handle_error "No video file found in directory '$dir'."
    fi
    
    local count
    count=$(echo "$video_files" | wc -l)
    
    if [ "$count" -gt 1 ]; then
        handle_error "More than one video file found in directory '$dir'. Please specify a single video file using --video."
    fi
    
    echo "$video_files" | head -n 1
}

# Function to find the subtitle file in the directory
find_subtitle_file() {
    local dir="$1"
    local subtitle_files
    subtitle_files=$(fd --glob "*English*.srt" . "$dir" | head -n 1)
    
    if [ -z "$subtitle_files" ]; then
        handle_error "No subtitle file found in directory '$dir'."
    fi
    
    echo "$subtitle_files"
}

# Function to find the directory by name in the search path
find_directory() {
    local dir_name="$1"
    local search_path="$2"
    local directory
    directory=$(fd --type d --glob "*$dir_name*" . "$search_path" | head -n 1)
    
    if [ -z "$directory" ]; then
        handle_error "No directory named '$dir_name' found in search path '$search_path'."
    fi
    
    echo "$directory"
}

# Function to check if the directory name contains "RARBG" or "VXT"
check_directory_name() {
    local dir="$1"
    if [[ "$dir" != *"RARBG"* && "$dir" != *"VXT"* ]]; then
        handle_error "Directory name does not contain 'RARBG' or 'VXT'."
    fi
}

# Function to check if input files exist
check_files() {
    if [ -n "$DIR_NAME" ] && [ -n "$DIR_SEARCH_PATH" ]; then
        DIRECTORY=$(find_directory "$DIR_NAME" "$DIR_SEARCH_PATH")
    fi

    if [ -n "$DIRECTORY" ]; then
        if [ "$ONLY_RARBG_VXT" = true ]; then
            check_directory_name "$DIRECTORY"
        fi
        INPUT_VIDEO=$(find_video_file "$DIRECTORY")
    fi

    if [ ! -f "$INPUT_VIDEO" ]; then
        handle_error "Video file '$INPUT_VIDEO' not found."
    fi

    if [ "$AUTO_FIND_SUB" = true ]; then
        SUBTITLE_FILE=$(find_subtitle_file "$(dirname "$INPUT_VIDEO")")
    fi

    if [ ! -f "$SUBTITLE_FILE" ]; then
        handle_error "Subtitle file '$SUBTITLE_FILE' not found."
    fi
}

# Function to embed subtitles and create a new output video
embed_subtitles() {
    local output_video
    local temp_video

    if [ "$KEEP_ORIGINAL_VIDEO" = true ]; then
        output_video="${INPUT_VIDEO%.*}-WithSubs.${INPUT_VIDEO##*.}"
        temp_video="$output_video"
    else
        temp_video="${INPUT_VIDEO%.*}_temp.${INPUT_VIDEO##*.}"
        mv "$INPUT_VIDEO" "$temp_video"
        output_video="$INPUT_VIDEO"
    fi

    # Run ffmpeg command
    ffmpeg -y \
        -i "$temp_video" \
        -i "$SUBTITLE_FILE" \
        -c copy \
        -c:s mov_text \
        -metadata:s:s:0 language=eng \
        "$output_video"

    # Check if ffmpeg command was successful
    if [ $? -eq 0 ]; then
        if [ "$KEEP_ORIGINAL_VIDEO" = false ]; then
            rm "$temp_video"
        fi
        msg "Subtitles embedded and video saved as '$output_video'."
        send_notification "Subtitles added" "$output_video" 10
    else
        if [ "$KEEP_ORIGINAL_VIDEO" = false ]; then
            mv "$temp_video" "$INPUT_VIDEO"
        fi
        handle_error "Failed to embed subtitles."
    fi
}

# Main function
main() {
    parse_arguments "$@"
    check_files
    embed_subtitles
}

# Execute the main function with all arguments passed to the script
main "$@"
