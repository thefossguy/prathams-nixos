#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash parted

set -x
BOOT_PART="${INTERMEDIATE_PART}1"
ROOT_PART="${INTERMEDIATE_PART}2"
STRG_PART="${INTERMEDIATE_PART}3"
HOME_PART="${INTERMEDIATE_PART}4"
BOOT_PART_SIZE='512M'
ROOT_PART_SIZE='512M'
STRG_PART_SIZE='128G'

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

+${STRG_PART_SIZE}
n
4


w
EOF
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;

fdisk -l "${OS_DRIVE}"

mkfs.fat  -F 32 -n nixboot "${BOOT_PART}"
parted -s "${OS_DRIVE}" -- set 1 esp on
mkfs.ext4 -F -L    nixroot "${ROOT_PART}"
mkfs.ext4 -F -L    nixstrg "${STRG_PART}"
mkfs.ext4 -F -L    nixhome "${HOME_PART}"

mount                    "${ROOT_PART}" "${MOUNT_PATH}"
mount --mkdir            "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount --mkdir -o noatime "${STRG_PART}" "${MOUNT_PATH}/nix"
mount --mkdir            "${HOME_PART}" "${MOUNT_PATH}/home"
