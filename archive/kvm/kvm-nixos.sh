#!/usr/bin/env bash

# Exit on error
set -e

# Variables
DISK="/dev/vda"
HOSTNAME="nixos"
TIMEZONE="Asia/Kolkata"
KEYMAP="us"
LOCALE="en_US.UTF-8"
USER="user"
PASSWORD="user"
REPO="https://github.com/dpi0/sh"
CLONE_LOCATION="/home/nixos/sh"

# Partition the disk
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 512MiB
parted $DISK -- mkpart primary 512MiB 100%
parted $DISK -- set 1 esp on

# Format the partitions
mkfs.fat -F32 -n boot ${DISK}1
mkfs.ext4 -L nixos ${DISK}2

# Mount the file systems
mount ${DISK}2 /mnt
mount --mkdir ${DISK}1 /mnt/boot

# Generate NixOS configuration
nixos-generate-config --root /mnt

# Copy the custom configuration
# cp configuration.nix /mnt/etc/nixos/
git clone --depth 1 "${REPO}" "${CLONE_LOCATION}"
cp "${CLONE_LOCATION}/nixos/configuration.nix" "/mnt/etc/nixos/"

# Install NixOS
nixos-install --root /mnt --no-root-passwd

# Finish
umount -R /mnt
reboot
