#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages

set -xeuf -o pipefail

BOOT_PART="${INTERMEDIATE_PART}1"
ROOT_PART="${INTERMEDIATE_PART}2"
HOME_PART="${INTERMEDIATE_PART}3"
BOOT_PART_SIZE='1G'
ROOT_PART_SIZE='256G'

cat << EOF | fdisk --wipe always "${OS_DRIVE}"
g
n
1

+${BOOT_PART_SIZE}
n
2

+${ROOT_PART_SIZE}
n
3


w
EOF
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;

mkfs.fat  -F 32 -n nixboot "${BOOT_PART}"
parted -s "${OS_DRIVE}" -- set 1 esp on
mkfs.xfs  -f -L    nixroot "${ROOT_PART}"
mkfs.xfs  -f -L    nixhome "${HOME_PART}"

mount -o async,lazytime,noatime "${ROOT_PART}" "${MOUNT_PATH}"
mount -o async,lazytime --mkdir "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount -o async,lazytime --mkdir "${HOME_PART}" "${MOUNT_PATH}/home"

fdisk -l "${OS_DRIVE}"
