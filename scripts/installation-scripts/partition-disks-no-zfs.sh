#!/usr/bin/env bash

set -xeuf -o pipefail

# do this first to fail early if this `exit 1`s
BOOT_UUID="$(MOUNT_PATH=boot ./scripts/installation-scripts/get-mount-path-uuid.sh)"
ROOT_UUID="$(MOUNT_PATH=root ./scripts/installation-scripts/get-mount-path-uuid.sh)"
HOME_UUID="$(MOUNT_PATH=home ./scripts/installation-scripts/get-mount-path-uuid.sh)"
VARL_UUID="$(MOUNT_PATH=var  ./scripts/installation-scripts/get-mount-path-uuid.sh)"

cat << EOF | fdisk --wipe always "${TARGET_DRIVE}"
g
n
1

+1G
n
2

+${ROOT_PART_SIZE}G
n
3

-6G
n
4


w
EOF
sync; sync; sync; sync;
hdparm -z "${TARGET_DRIVE}"

BOOT_PART="${INTERMEDIATE_PART}1"
ROOT_PART="${INTERMEDIATE_PART}2"
HOME_PART="${INTERMEDIATE_PART}3"
VARL_PART="${INTERMEDIATE_PART}4"
mkfs.fat -F 32 -n nixboot "${BOOT_PART}" -i "${BOOT_UUID//-/}"
mkfs.xfs -f -L    nixroot "${ROOT_PART}" -m uuid="${ROOT_UUID}"
mkfs.xfs -f -L    nixhome "${HOME_PART}" -m uuid="${HOME_UUID}"
mkfs.xfs -f -L    nixvarp "${VARL_PART}" -m uuid="${VARL_UUID}"
parted -s "${TARGET_DRIVE}" -- set 1 esp on

BY_UUID_PATH='/dev/disk/by-uuid'
BOOT_PART="${BY_UUID_PATH}/${BOOT_UUID}"
ROOT_PART="${BY_UUID_PATH}/${ROOT_UUID}"
HOME_PART="${BY_UUID_PATH}/${HOME_UUID}"
VARL_PART="${BY_UUID_PATH}/${VARL_UUID}"
mount -o async,lazytime,relatime         "${ROOT_PART}" "${MOUNT_PATH}"
mount -o async,lazytime,relatime --mkdir "${BOOT_PART}" "${MOUNT_PATH}/boot"
mount -o async,lazytime,relatime --mkdir "${HOME_PART}" "${MOUNT_PATH}/home"
mount -o async,lazytime,relatime --mkdir "${VARL_PART}" "${MOUNT_PATH}/var"
