#!/usr/bin/env bash
set -euo pipefail

# Defaults
declare -a INPUT_PATHS=()
declare -a EXCLUDE_PATHS=()
declare -a TAGS=()
RESTIC_REPO=""
RESTIC_PASSFILE=""
LOG_FILE="$HOME/restic-backup.log"
ENABLE_RETENTION="false"
CONFIG_FILE=""

# Early pass to extract --config if provided
ARGS=("$@")
for ((i = 0; i < $#; i++)); do
	if [[ "${ARGS[$i]}" == "--config" && $((i + 1)) -lt $# ]]; then
		CONFIG_FILE="${ARGS[$((i + 1))]}"
		unset 'ARGS[i]'
		unset 'ARGS[i+1]'
		break
	fi
done

# Reconstruct remaining args
set -- "${ARGS[@]}"

# Load config if specified
if [[ -n "$CONFIG_FILE" ]]; then
	if [[ -f "$CONFIG_FILE" ]]; then
		echo "Loading config from $CONFIG_FILE"
		# shellcheck disable=SC1090
		source "$CONFIG_FILE"
		IFS=' ' read -r -a INPUT_PATHS <<<"${INPUT_PATHS:-}"
		IFS=' ' read -r -a EXCLUDE_PATHS <<<"${EXCLUDE_PATHS:-}"
		IFS=' ' read -r -a TAGS <<<"${TAGS:-}"
	else
		echo "ERROR: Config file '$CONFIG_FILE' not found." >&2
		exit 7
	fi
fi

# Retention options
KEEP_LAST=""
KEEP_HOURLY=""
KEEP_DAILY=""
KEEP_WEEKLY=""
KEEP_MONTHLY=""
KEEP_YEARLY=""

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --config FILE           Load settings from a .env-style config file
  --input PATH            Directory to include in backup (can repeat)
  --exclude PATH          Directory or pattern to exclude (can repeat)
  --tag TAG               Tag to apply to snapshot (can repeat)
  --repo REPO             Restic repository location (required)
  --password-file FILE    Restic password file (required)
  --log-file FILE         Log file path (default: $HOME/restic-backup.log)

  --retention true        Enable retention policy (optional)
  --keep-last N           Keep only the last N snapshots (overrides other keep-* options)
  --keep-hourly N         Number of hourly snapshots to keep
  --keep-daily N          Number of daily snapshots to keep
  --keep-weekly N         Number of weekly snapshots to keep
  --keep-monthly N        Number of monthly snapshots to keep
  --keep-yearly N         Number of yearly snapshots to keep

  -h, --help              Show this help message and exit

Examples:
  Basic backup with tags and retention:
    ./restic-backup-wrapper.sh \\
      --input /etc \\
      --input /home/user \\
      --exclude /home/user/tmp \\
      --tag daily \\
      --tag server1 \\
      --repo /mnt/restic \\
      --password-file ~/.restic-pass \\
      --retention true \\
      --keep-weekly 4

  Backup with only --keep-last retention:
    ./restic-backup-wrapper.sh \\
      --input /var/www \\
      --tag web \\
      --repo /mnt/backup \\
      --password-file ~/.restic-pass \\
      --retention true \\
      --keep-last 10
EOF
	exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
	case "$1" in
	--input)
		INPUT_PATHS+=("$2")
		shift 2
		;;
	--exclude)
		EXCLUDE_PATHS+=("$2")
		shift 2
		;;
	--tag)
		TAGS+=("$2")
		shift 2
		;;
	--repo)
		RESTIC_REPO="$2"
		shift 2
		;;
	--password-file)
		RESTIC_PASSFILE="$2"
		shift 2
		;;
	--log-file)
		LOG_FILE="$2"
		shift 2
		;;
	--retention)
		ENABLE_RETENTION="$2"
		shift 2
		;;
	--keep-last)
		KEEP_LAST="$2"
		shift 2
		;;
	--keep-hourly)
		KEEP_HOURLY="$2"
		shift 2
		;;
	--keep-daily)
		KEEP_DAILY="$2"
		shift 2
		;;
	--keep-weekly)
		KEEP_WEEKLY="$2"
		shift 2
		;;
	--keep-monthly)
		KEEP_MONTHLY="$2"
		shift 2
		;;
	--keep-yearly)
		KEEP_YEARLY="$2"
		shift 2
		;;
	-h | --help) usage ;;
	*)
		echo "Unknown option: $1" >&2
		usage
		;;
	esac
done

# Check required args
if [[ -z "$RESTIC_REPO" || -z "$RESTIC_PASSFILE" ]]; then
	echo "ERROR: --repo and --password-file are required." >&2
	usage
fi

# Redirect repo to log
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== $(date): Starting restic backup ====="

# Check binary
if ! command -v restic &>/dev/null; then
	echo "ERROR: restic not found in PATH." >&2
	exit 2
fi

# Check paths
[[ -d "$RESTIC_REPO" ]] || {
	echo "ERROR: Repo dir '$RESTIC_REPO' does not exist." >&2
	exit 3
}
[[ -f "$RESTIC_PASSFILE" ]] || {
	echo "ERROR: Password file '$RESTIC_PASSFILE' not found." >&2
	exit 4
}

for dir in "${INPUT_PATHS[@]}"; do
	[[ -d "$dir" ]] || {
		echo "ERROR: Input path '$dir' not valid." >&2
		exit 5
	}
done
for dir in "${EXCLUDE_PATHS[@]}"; do
	[[ -d "$dir" ]] || {
		echo "ERROR: Exclude path '$dir' not valid." >&2
		exit 6
	}
done
for tag in "${TAGS[@]}"; do
	RESTIC_ARGS+=(--tag "$tag")
done

# Export credentials
export RESTIC_REPOSITORY="$RESTIC_REPO"
export RESTIC_PASSWORD_FILE="$RESTIC_PASSFILE"

# Run backup
RESTIC_ARGS=(backup "${INPUT_PATHS[@]}")
for excl in "${EXCLUDE_PATHS[@]}"; do
	RESTIC_ARGS+=(--exclude "$excl")
done
for tag in "${TAGS[@]}"; do
	RESTIC_ARGS+=(--tag "$tag")
done

echo "Running command: restic ${RESTIC_ARGS[*]}"
restic "${RESTIC_ARGS[@]}"

# Retention
if [[ "$ENABLE_RETENTION" == "true" ]]; then
	echo "Applying retention policy..."

	FORGET_ARGS=(forget)

	if [[ -n "$KEEP_LAST" ]]; then
		echo "Using --keep-last $KEEP_LAST. All other retention options will be ignored."
		FORGET_ARGS+=(--keep-last "$KEEP_LAST")
	else
		[[ -n "$KEEP_HOURLY" ]] && FORGET_ARGS+=(--keep-hourly "$KEEP_HOURLY")
		[[ -n "$KEEP_DAILY" ]] && FORGET_ARGS+=(--keep-daily "$KEEP_DAILY")
		[[ -n "$KEEP_WEEKLY" ]] && FORGET_ARGS+=(--keep-weekly "$KEEP_WEEKLY")
		[[ -n "$KEEP_MONTHLY" ]] && FORGET_ARGS+=(--keep-monthly "$KEEP_MONTHLY")
		[[ -n "$KEEP_YEARLY" ]] && FORGET_ARGS+=(--keep-yearly "$KEEP_YEARLY")
	fi

	if [[ ${#FORGET_ARGS[@]} -eq 1 ]]; then
		echo "⚠️  --retention true was set, but no retention options were provided!"
		echo "    No snapshots were pruned. Use --keep-* or --keep-last."
	else
		FORGET_ARGS+=(--prune)
		echo "Running: restic ${FORGET_ARGS[*]}"
		restic "${FORGET_ARGS[@]}"
		echo "Retention policy applied."
	fi
else
	echo "⚠️  Retention not enabled. Snapshots will accumulate unless --retention true is used."
fi

echo "===== $(date): Backup completed ====="
