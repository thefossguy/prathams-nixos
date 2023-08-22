#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages bash

set -x
if [[ ${EUID} -ne 0 ]]; then
    >&2 echo "$0: please run this script as root"
    exit 1
fi


if ! ping -c 1 google.com > /dev/null; then
    >&2 echo "$0: not connected to the network"
    exit 1
fi

if [[ -z $1 || -z $2 || -z $3 ]]; then
    >&2 echo "$0: missing arg(s) for 'OS drive', 'hostname' and 'disk partition layout'"
    exit 1
fi

OS_DRIVE=$1
NETWORKING_HOSTNAME=$2
PARTITION_LAYOUT_TYPE=$3

if [[ ${PARTITION_LAYOUT_TYPE} == "desktop" ]]; then
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/desktop-partitions.sh"
elif [[ ${PARTITION_LAYOUT_TYPE} == "rpi" ]]; then
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/raspberry-pi-partitions.sh"
elif [[ ${PARTITION_LAYOUT_TYPE} == "virt"  ]]; then
    PARTITION_LAYOUT_TYPE="$(pwd)/scripts/virt-partitions.sh"
else
    >&2 echo "$0: invalid arg for 'disk partition layout'"
    >&2 echo "$0: possible values are 'desktop', 'rpi', 'virt'"
    exit 1
fi

umount -R /mnt &> /dev/null

# partition, format and mount
"${PARTITION_LAYOUT_TYPE}" "${OS_DRIVE}"

# prepare installation
mkdir -p /mnt/etc/nixos
nixos-generate-config --root /mnt
cp -vR nixos-configuration/* /mnt/etc/nixos

# generate 'networking.hostId' for ZFS
# and other host-specific configurations
./scripts/deviation.sh "${NETWORKING_HOSTNAME}" "${PARTITION_LAYOUT_TYPE}"

# install nixos
nixos-install --no-root-password

# very very initial setup for 'pratham'
mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
mount -o bind /sys /mnt/sys
mount -o bind,ro /etc/resolv.conf /mnt/etc/resolv.conf
chroot /mnt /nix/var/nix/profiles/system/activate
cp scripts/chroot-as-pratham.sh /mnt/home/pratham/
chroot /mnt /run/current-system/sw/bin/sudo -i -u pratham bash /home/pratham/chroot-as-pratham.sh
rm /mnt/home/pratham/chroot-as-pratham.sh

# done!
umount -R /mnt
