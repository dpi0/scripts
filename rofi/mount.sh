#!/usr/bin/env bash

device_list() {
  lsblk -rpno NAME,SIZE,LABEL,FSTYPE,MOUNTPOINTS |
    grep -v "loop" |
    awk '
      {
        name  = $1
        size  = $2
        label = $3
        fstype = $4
        mnt   = $5

        if (label == "")  label  = "-"
        if (fstype == "") fstype = "-"
        if (mnt == "")    mnt    = "-"

        printf "%-20s %-8s %-18s %-8s %s\n", name, size, label, fstype, mnt
      }
    '
}

mountpoint_from_dev() {
  local dev="$1"
  local label

  label=$(lsblk -no LABEL "$dev" 2>/dev/null | head -n1)

  if [ -n "$label" ]; then
    printf '/mnt/%s\n' "$label"
  else
    printf '/mnt/%s\n' "$(basename "$dev")"
  fi
}

mount_dev() {
  local dev="$1"
  local mnt="$2"

  if findmnt -rn "$dev" >/dev/null 2>&1; then
    notify-send "Mount" "$dev is already mounted"
    printf "%s is already mounted\n" "$dev"
    return 0
  fi

  if pkexec mount --mkdir "$dev" "$mnt"; then
    notify-send "Mount" "Mounted $dev at $mnt"
    printf "Mounted %s at %s\n" "$dev" "$mnt"
  else
    notify-send "Mount failed" "Failed to mount $dev"
    printf "Failed to mount %s\n" "$dev" >&2
    return 1
  fi
}

unmount_dev() {
  local dev="$1"

  if ! findmnt -rn "$dev" >/dev/null 2>&1; then
    notify-send "Unmount" "$dev is not mounted"
    printf "%s is not mounted\n" "$dev"
    return 0
  fi

  if pkexec umount "$dev"; then
    notify-send "Unmount" "Unmounted $dev"
    printf "Unmounted %s\n" "$dev"
  else
    notify-send "Unmount failed" "Failed to unmount $dev"
    printf "Failed to unmount %s\n" "$dev" >&2
    return 1
  fi
}

entries="$(device_list)"

selection=$(printf "%s\n" "$entries" | rofi -dmenu \
  -p "Mount /dev device" \
  -kb-custom-1 "Ctrl+u" \
  -mesg "ENTER: mount | CTRL+U: unmount")

ret=$?

# If nothing selected or rofi was cancelled
[ -z "$selection" ] && exit 0

# First field is the device path
dev=${selection%% *}

mountpoint="$(mountpoint_from_dev "$dev")"

case "$ret" in
0)
  mount_dev "$dev" "$mountpoint"
  ;;
10)
  unmount_dev "$dev"
  ;;
*)
  # Any other key/exit code: do nothing
  exit 0
  ;;
esac
