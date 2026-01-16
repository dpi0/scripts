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
  "   Mount - 0x-media\n\
   Mount - 0x-downloads\n\
  Unmount - 0x-media\n\
  Unmount - 0x-downloads" |
  $ROFI)

case "$CHOICE" in
"   Mount - 0x-media")
  if pkexec mount --mkdir -t cifs //10.0.0.10/hdd-Media /mnt/0x-media -o "$OPTS"; then
    notify_ok "Mounted /mnt/0x-media"
  else
    notify_err "Failed to mount /mnt/0x-media"
  fi
  ;;
"   Mount - 0x-downloads")
  if pkexec mount --mkdir -t cifs //10.0.0.10/hdd-Downloads /mnt/0x-downloads -o "$OPTS"; then
    notify_ok "Mounted /mnt/0x-downloads"
  else
    notify_err "Failed to mount /mnt/0x-downloads"
  fi
  ;;
"  Unmount - 0x-media")
  if pkexec umount /mnt/0x-media; then
    notify_ok "Unmounted /mnt/0x-media"
  else
    notify_err "Failed to unmount /mnt/0x-media"
  fi
  ;;
"  Unmount - 0x-downloads")
  if pkexec umount /mnt/0x-downloads; then
    notify_ok "Unmounted /mnt/0x-downloads"
  else
    notify_err "Failed to unmount /mnt/0x-downloads"
  fi
  ;;
esac
