#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages bash

OS_DRIVE="${1}"
RASP_PART="${OS_DRIVE}p1"
BOOT_PART="${OS_DRIVE}p2"
ROOT_PART="${OS_DRIVE}p3"
HOME_PART="${OS_DRIVE}p4"
VARL_PART="${OS_DRIVE}p5"

# partitioning
cat << EOF | fdisk --wipe always "${OS_DRIVE}"
g
n
1

+64M
n
2

+1G
n
3

+80G
n
4

+32G
n
5


t
1
0b
t
2
0b
w
EOF
parted -s "${OS_DRIVE}" -- set 1 esp on
parted -s "${OS_DRIVE}" -- set 2 esp on
sync; sync; sync; sync;

fdisk -l "${OS_DRIVE}"

# formatting
mkfs.fat -F 32 -n raspuefi "${RASP_PART}"
mkfs.fat -F 32 -n nixuefi  "${BOOT_PART}"
mkfs.ext4 -F -L nixos      "${ROOT_PART}"
mkfs.ext4 -F -L home       "${HOME_PART}"
mkfs.ext4 -F -L varpart    "${VARL_PART}"

# mounting
mount         "${ROOT_PART}" /mnt
mount --mkdir "${BOOT_PART}" /mnt/boot
mount --mkdir "${HOME_PART}" /mnt/home
mount --mkdir "${VARL_PART}" /mnt/var
mount --mkdir "${RASP_PART}" /mnt/raspberry-pi/firmware

# get firmware
./scripts/get-raspi-4-firmware.sh
cp -r out/* /mnt/raspberry-pi/firmware/
umount /mnt/raspberry-pi/firmware
