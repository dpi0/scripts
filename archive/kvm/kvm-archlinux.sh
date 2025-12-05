#!/usr/bin/env bash

# enables automatic exit from a script when a command fails
set -e

DISK="/dev/vda"
HOSTNAME="archkvm"
LOCALE_LANG_COMPLETE="en_US.UTF-8 UTF-8"
LOCALE_LANG="en_US.UTF-8"
TIMEZONE="Asia/Kolkata"
KEYMAP="us"
FONT="ter-132n"
USERNAME="admin"
USERGROUP="wheel"
USER_PASSWORD="admin"
# ROOT_PASSWORD="root"

check_root() { [[ $(id -u) -eq 0 ]] || {
  echo "ERROR: Run this script as root"
  exit 1
}; }
check_uefi() { [[ -d /sys/firmware/efi ]] || {
  echo "ERROR: UEFI required"
  exit 1
}; }

echo " █████╗ ██████╗  ██████╗██╗  ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗"
echo "██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝"
echo "███████║██████╔╝██║     ███████║    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ "
echo "██╔══██║██╔══██╗██║     ██╔══██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ "
echo "██║  ██║██║  ██║╚██████╗██║  ██║    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗"
echo "╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
echo "                                                                          "

preliminary_setup() {
  # setfont "$FONT"
  loadkeys "$KEYMAP"
  timedatectl set-timezone "$TIMEZONE"
  timedatectl set-ntp true
  # reflector --verbose -c India -l 10 -p https --sort rate --save /etc/pacman.d/mirrorlist
}

partitioning() {
  parted -s "$DISK" mklabel gpt
  parted -s "$DISK" mkpart primary fat32 1MiB 512MiB set 1 esp on
  parted -s "$DISK" mkpart primary ext4 512MiB 100%
  mkfs.fat -F32 "$DISK"1
  mkfs.ext4 "$DISK"2
  mount "$DISK"2 /mnt
  mount --mkdir "$DISK"1 /mnt/boot
}

install_base() {
  pacstrap /mnt base linux-lts vim sudo less intel-ucode qemu-guest-agent
  genfstab -U /mnt >>/mnt/etc/fstab
}

configure_system() {
  # TIMEZONE
  ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
  hwclock -w
  # LOCALE
  echo "$LOCALE_LANG_COMPLETE" >>/etc/locale.gen
  locale-gen
  echo "LANG=$LOCALE_LANG" >>/etc/locale.conf
  echo "KEYMAP=$KEYMAP" >>/etc/vconsole.conf
  echo "FONT=$FONT" >>/etc/vconsole.conf
  echo "$HOSTNAME" >>/etc/hostname
  # USER
  useradd -mg "$USERGROUP" "$USERNAME"
  echo "$USERNAME:$USER_PASSWORD" | chpasswd
  echo "%$USERGROUP ALL=(ALL:ALL) ALL" >>/etc/sudoers
  # PACMAN
  sed -i 's/^#Color/Color/; s/^#ParallelDownloads/ParallelDownloads/; /Color/a ILoveCandy' /etc/pacman.conf
  pacman -S --noconfirm git openssh pacman-contrib networkmanager
  # ENABLE SERVICES
  systemctl enable fstrim.timer paccache.timer NetworkManager sshd
}

setup_bootloader() {
  bootctl --path=/boot install
  {
    echo default arch
    echo timeout 0
    echo console-mode max
    echo editor no
  } >>/boot/loader/loader.conf

  UUID=$(blkid -s UUID -o value "$DISK"2)
  {
    echo title Arch Linux
    echo linux /vmlinuz-linux-lts
    echo initrd /initramfs-linux-lts.img
    echo options root=UUID="$UUID" quiet rw
  } >>/boot/loader/entries/arch.conf
}

main() {
  check_root
  check_uefi
  preliminary_setup
  partitioning
  install_base
  cp "$0" /mnt/root/install.sh
  arch-chroot /mnt /bin/bash /root/install.sh chroot
  umount -R /mnt && reboot
}

main_chroot() {
  configure_system
  setup_bootloader
}

[[ "$1" == "chroot" ]] && main_chroot || main
