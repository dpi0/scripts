#!/usr/bin/env bash

set -e

DISK="/dev/vda"
HOSTNAME="kvm-debian"
LOCALE_LANG="en_US.UTF-8"
TIMEZONE="Asia/Kolkata"
KEYMAP="us"
USERNAME="user"
USERGROUP="sudo"
USER_PASSWORD="user"

check_root() { [[ $(id -u) -eq 0 ]] || {
  echo "ERROR: Run this script as root"
  exit 1
}; }

echo "██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗"
echo "██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║"
echo "██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║"
echo "██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║"
echo "██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║"
echo "╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
echo "                                             "

set_locale_and_timezone() {
  chroot /mnt ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
  chroot /mnt hwclock -w
  chroot /mnt echo "$LOCALE_LANG UTF-8" > /etc/locale.gen
  chroot /mnt locale-gen
  chroot /mnt echo "LANG=$LOCALE_LANG" > /etc/default/locale
  chroot /mnt echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
  chroot /mnt localectl set-locale LANG=en_US.UTF-8
}

partitioning() {
  # sudo su
  apt update && apt install -y debootstrap parted dosfstools arch-install-scripts
  parted -s "$DISK" mklabel gpt
  parted -s "$DISK" mkpart ESP fat32 1MiB 512MiB set 1 esp on
  parted -s "$DISK" mkpart primary ext4 512MiB 100%
  mkfs.fat -F32 "${DISK}1"
  mkfs.ext4 "${DISK}2"
  mount "${DISK}2" /mnt
  mount --mkdir "${DISK}1" /mnt/boot
}

install_base() {
  debootstrap --arch=amd64 stable /mnt "https://deb.debian.org/debian"
  mount --make-rslave --rbind /proc /mnt/proc
  mount --make-rslave --rbind /sys /mnt/sys
  mount --make-rslave --rbind /dev /mnt/dev
  mount --make-rslave --rbind /run /mnt/run
  genfstab -U /mnt >> /mnt/etc/fstab
  sed -i '/# \/dev\/sr0/,$d' /mnt/etc/fstab
}

configure_system() {
  chroot /mnt apt update && chroot /mnt apt install -y vim locales linux-image-amd64 sudo network-manager dosfstools ssh lsb-release grub-efi

  CODENAME=$(chroot /mnt lsb_release --codename --short)
  cat > /mnt/etc/apt/sources.list << HEREDOC
deb https://deb.debian.org/debian/ $CODENAME main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware
deb https://deb.debian.org/debian/ $CODENAME-updates main contrib non-free non-free-firmware
HEREDOC

  echo "$HOSTNAME" > /mnt/etc/hostname
  chroot /mnt useradd -mG "$USERGROUP" "$USERNAME" -s /bin/bash
  echo "$USERNAME:$USER_PASSWORD" | chroot /mnt chpasswd

  chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  chroot /mnt update-grub
}

main() {
  # check_root
  partitioning
  install_base
  configure_system
  set_locale_and_timezone
  umount -R /mnt && reboot
}

main
