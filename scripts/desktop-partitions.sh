#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash

set -x
BOOT_PART="${INTERMEDIATE_PART}1"
ROOT_PART="${INTERMEDIATE_PART}2"
HOME_PART="${INTERMEDIATE_PART}3"
BOOT_PART_SIZE='1G'
ROOT_PART_SIZE='128G'

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


t
1
1
w
EOF
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;

fdisk -l "${OS_DRIVE}"

mkfs.fat  -F 32 -n nixboot "${BOOT_PART}"
mkfs.ext4 -F -L    nixroot "${ROOT_PART}"
mkfs.ext4 -F -L    nixhome "${HOME_PART}"

mount         "${ROOT_PART}" "${MOUNT_PATH}"
mount --mkdir "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount --mkdir "${HOME_PART}" "${MOUNT_PATH}/home"
