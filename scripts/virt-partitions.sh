#!/usr/bin/env bash

OS_DRIVE=$1
BOOT_PART="${OS_DRIVE}1"
ROOT_PART="${OS_DRIVE}2"
HOME_PART="${OS_DRIVE}3"

# partitioning
cat << EOF | fdisk --wipe always ${OS_DRIVE}
g
n
1

+1G
n
2

+40G
n
3


w
EOF
parted -s ${OS_DRIVE} -- set 1 esp on
sync; sync; sync; sync;

fdisk -l ${OS_DRIVE}

# formatting
mkfs.fat -F 32 -n boot    ${BOOT_PART}
mkfs.ext4 -F -L nixos     ${ROOT_PART}
mkfs.ext4 -F -L home      ${HOME_PART}

# mounting
mount         ${ROOT_PART} /mnt
mount --mkdir ${BOOT_PART} /mnt/boot
mount --mkdir ${HOME_PART} /mnt/home
