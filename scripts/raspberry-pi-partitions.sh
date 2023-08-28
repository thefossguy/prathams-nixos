#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash parted

set -x
RASP_PART="${INTERMEDIATE_PART}1"
BOOT_PART="${INTERMEDIATE_PART}2"
ROOT_PART="${INTERMEDIATE_PART}3"
STRG_PART="${INTERMEDIATE_PART}4"
HOME_PART="${INTERMEDIATE_PART}5"
VARL_PART="${INTERMEDIATE_PART}6"
RASP_PART_SIZE='64M'
BOOT_PART_SIZE='512M'
ROOT_PART_SIZE='512M'
STRG_PART_SIZE='80G'
HOME_PART_SIZE='32G'

cat << EOF | fdisk --wipe always "${OS_DRIVE}"
g
n
1

+${RASP_PART_SIZE}
n
2

+${BOOT_PART_SIZE}
n
3

+${ROOT_PART_SIZE}
n
4

+${STRG_PART_SIZE}
n
5

+${HOME_PART_SIZE}
n
6


t
1
0b
t
2
0b
w
EOF
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;

fdisk -l "${OS_DRIVE}"

mkfs.fat  -F 32 -n pftf    "${RASP_PART}"
mkfs.fat  -F 32 -n nixboot "${BOOT_PART}"
parted -s "${OS_DRIVE}" -- set 1 esp on
parted -s "${OS_DRIVE}" -- set 2 esp on
mkfs.ext4 -F -L    nixroot "${ROOT_PART}"
mkfs.ext4 -F -L    nixstrg "${STRG_PART}"
mkfs.ext4 -F -L    nixhome "${HOME_PART}"
mkfs.ext4 -F -L    nixvarp "${VARL_PART}"

mount                    "${ROOT_PART}" "${MOUNT_PATH}"
mount --mkdir            "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount --mkdir -o noatime "${STRG_PART}" "${MOUNT_PATH}/nix"
mount --mkdir            "${HOME_PART}" "${MOUNT_PATH}/home"
mount --mkdir            "${VARL_PART}" "${MOUNT_PATH}/var"
mount --mkdir            "${RASP_PART}" "${MOUNT_PATH}/raspberry-pi/firmware"

"$(pwd)/scripts/get-raspi-4-firmware.sh"
cp -r "$(pwd)"/out/* "${MOUNT_PATH}/raspberry-pi/firmware"
umount "${MOUNT_PATH}/raspberry-pi/firmware"
