#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages

set -xeuf -o pipefail

export RPI_FIRMWARE_PATH="${MOUNT_PATH}/raspberry-pi/firmware"
RASP_PART="${INTERMEDIATE_PART}1"
BOOT_PART="${INTERMEDIATE_PART}2"
ROOT_PART="${INTERMEDIATE_PART}3"
HOME_PART="${INTERMEDIATE_PART}4"
VARL_PART="${INTERMEDIATE_PART}5"
RASP_PART_SIZE='64M'
BOOT_PART_SIZE='1G'
ROOT_PART_SIZE='80G'
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

+${HOME_PART_SIZE}
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
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;

mkfs.fat  -F 32 -n pftf    "${RASP_PART}" -i "${RPIF_UUID}"
mkfs.fat  -F 32 -n nixboot "${BOOT_PART}" -i "${BOOT_UUID}"
parted -s "${OS_DRIVE}" -- set 1 esp on
parted -s "${OS_DRIVE}" -- set 2 esp on
mkfs.xfs  -f -L    nixroot "${ROOT_PART}"
mkfs.xfs  -f -L    nixhome "${HOME_PART}"
mkfs.xfs  -f -L    nixvarp "${VARL_PART}"

mount -o async,lazytime,noatime "${ROOT_PART}" "${MOUNT_PATH}"
mount -o async,lazytime --mkdir "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount -o async,lazytime --mkdir "${HOME_PART}" "${MOUNT_PATH}/home"
mount -o async,lazytime --mkdir "${VARL_PART}" "${MOUNT_PATH}/var"
mount -o async,lazytime --mkdir "${RASP_PART}" "${MOUNT_PATH}/raspberry-pi/firmware"

"$(pwd)/scripts/get-raspi-4-firmware.sh"
umount "${MOUNT_PATH}/raspberry-pi/firmware"

fdisk -l "${OS_DRIVE}"
