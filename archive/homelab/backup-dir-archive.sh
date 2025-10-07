#!/usr/bin/env bash

LOG_FILE="$HOME/backup-dir-archive.log"

# === Logging Function ===
log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

show_help() {
  cat << EOF
Usage: $0 --input <input_dir> --output <output_dir> [--keep-last <n>]

Archives the input directory as a .tar.gz file into the output directory.
The archive filename is based on the input path and a timestamp.

Options:
  --input       Path to the directory to archive
  --output      Path to the directory to save the archive
  --keep-last n Retain only the last n archives for this input path (n must be ≥ 0)
  --help        Show this help message

Example:
  $0 --input \$HOME/temp/pkgs --output \$HOME/backup --keep-last 3

Result:
  \$HOME/backup/_home_bob_temp_pkgs_11-May-2025_19-44.tar.gz
EOF
}

# Show help if no args
if [[ $# -eq 0 ]]; then
  show_help
  exit 1
fi

# Defaults
keep_last=0

# Parse args
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --input)
      input="$2"
      shift
      ;;
    --output)
      output="$2"
      shift
      ;;
    --keep-last)
      keep_last="$2"
      if ! [[ "$keep_last" =~ ^[0-9]+$ ]]; then
        log ERROR "--keep-last must be a non-negative integer"
        exit 1
      fi
      shift
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      log ERROR "Unknown parameter '$1'"
      show_help
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$input" || -z "$output" ]]; then
  log ERROR "--input and --output must be specified"
  show_help
  exit 1
fi

if [[ ! -d "$input" ]]; then
  log ERROR "Input '$input' is not a directory"
  exit 1
fi

if [[ ! -d "$output" ]]; then
  log ERROR "Output '$output' is not a directory"
  exit 1
fi

# Normalize paths
input=$(realpath "$input")
output=$(realpath "$output")
timestamp=$(date +"%d-%b-%Y_%H-%M-%S")
input_sanitized=$(echo "$input" | tr '/' '_')
archive_name="${input_sanitized}_${timestamp}.tar.gz"
archive_path="${output}/${archive_name}"

log INFO "Creating archive from '$input' to '$archive_path'"
if tar -czf "$archive_path" -C "$(dirname "$input")" "$(basename "$input")"; then
  log INFO "Archive created: $archive_path"
else
  log ERROR "Failed to create archive"
  exit 1
fi

# Retention policy
if [[ "$keep_last" -gt 0 ]]; then
  pattern="${output}/${input_sanitized}_*.tar.gz"
  old_archives=($(ls -1t $pattern 2> /dev/null | tail -n +$(($keep_last + 1))))
  for f in "${old_archives[@]}"; do
    log INFO "Deleting old archive: $f"
    rm -f -- "$f"
  done
fi
