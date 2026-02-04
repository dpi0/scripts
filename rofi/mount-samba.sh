#!/usr/bin/env bash

ROFI="rofi -dmenu -i -p SMB"
CREDS="/home/dpi0/.smbcredentials"
OPTS="credentials=$CREDS,username=admin,uid=1000,gid=1000,vers=3.1.1"

notify_ok() {
  dunstify -a "SMB Mount" "$1"
}

notify_err() {
  dunstify -a "SMB Mount" -u critical "$1"
}

# NOTE: the indentation here will affect the rofi text
# WARNING: the choice text here must match the case choice
CHOICE=$(printf \
  "   Mount - 0x-Library\n\
   Mount - 0x-Downloads\n\
  Unmount - 0x-Library\n\
  Unmount - 0x-Downloads" |
  $ROFI)

case "$CHOICE" in
"   Mount - 0x-Library")
  if pkexec mount --mkdir -t cifs "//10.0.0.10/0x3110 Library" /mnt/0x-Library -o "$OPTS"; then
    notify_ok "Mounted /mnt/0x-Library"
  else
    notify_err "Failed to mount /mnt/0x-Library"
  fi
  ;;
"   Mount - 0x-Downloads")
  if pkexec mount --mkdir -t cifs "//10.0.0.10/0x3110 Downloads" /mnt/0x-Downloads -o "$OPTS"; then
    notify_ok "Mounted /mnt/0x-Downloads"
  else
    notify_err "Failed to mount /mnt/0x-Downloads"
  fi
  ;;
"  Unmount - 0x-Library")
  if pkexec umount /mnt/0x-Library; then
    notify_ok "Unmounted /mnt/0x-Library"
  else
    notify_err "Failed to unmount /mnt/0x-Library"
  fi
  ;;
"  Unmount - 0x-Downloads")
  if pkexec umount /mnt/0x-Downloads; then
    notify_ok "Unmounted /mnt/0x-Downloads"
  else
    notify_err "Failed to unmount /mnt/0x-Downloads"
  fi
  ;;
esac
