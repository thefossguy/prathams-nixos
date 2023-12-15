#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages parted pciutils

# not using 'set -uf' because file globbing is necessary
# and we will be checking if vars are empty or not, manually
set -xe -o pipefail

date +%Y/%m/%d\ %H:%M:%S
if [ "$(id -u)" -ne 0 ]; then
    >&2 echo "$0: please run this script as root"
    exit 1
fi

if ! ping -c 1 google.com > /dev/null; then
    >&2 echo "$0: not connected to the internet... exiting..."
    exit 1
fi

if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then
    >&2 echo "$0: missing args for either 'OS drive', 'hostname' or 'disk partition layout'"
    exit 1
fi

if sudo dmesg | grep EFI | grep ' by Das U-Boot'; then
    CAN_TOUCH_EFI_VARS='false'
else
    CAN_TOUCH_EFI_VARS='true'
fi
grep 'AuthenticAMD' /proc/cmdline && export CPU_VENDOR='AMD'
grep 'GenuineIntel' /proc/cmdline && export CPU_VENDOR='Intel'
lspci | grep -i 'NVIDIA' && export GPU_VENDOR='NVIDIA'
dmesg | grep 'can'\''t read MAC address, setting random one' && export SPECIAL_IP_ADDR="hehe"
NETWORKING_HOSTID="$(head -c4 /dev/urandom | od -A none -t x4 | xargs)"
BOOT_UUID="$(head -c4 /dev/urandom | od -A none -t x4 | xargs)"
RPIF_UUID="$(head -c4 /dev/urandom | od -A none -t x4 | xargs)"
NETWORKING_INTERFACE="$(grep -i "eth\|enp\|enabcm\|wl" /proc/net/dev | sort | head -n 1 | awk -F : '{print $1}')"
TOTAL_MEM_KIB=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
export OS_DRIVE="${1}"
export MACHINE_HOSTNAME="${2}"
export PARTITION_LAYOUT="${3}"
export MOUNT_PATH='/mnt'
export CUSTOM_HOST_CONFIG="${MOUNT_PATH}/etc/nixos/host-specific-configuration.nix"
export TOTAL_MEM_GIB=$(( TOTAL_MEM_KIB / 1024 / 1024 ))
export NETWORKING_HOSTID
export BOOT_UUID
export RPIF_UUID
export NETWORKING_INTERFACE
export CAN_TOUCH_EFI_VARS

if [ "${TOTAL_MEM_GIB}" -lt 3 ]; then
    >&2 echo "$0: You might get an OOM with less than 3GiB of RAM."
    exit 1
fi

# make sure that $MOUNT_PATH is empty
# otherwise, bad things happen
mount | grep "${OS_DRIVE}" && umount --recursive --force "${MOUNT_PATH}"

if [ -b "${OS_DRIVE}" ]; then
    if echo "${OS_DRIVE}" | grep "sd\|vd"; then
        export INTERMEDIATE_PART="${OS_DRIVE}"
    elif echo "${OS_DRIVE}" | grep "mmcblk\|nvme"; then
        export INTERMEDIATE_PART="${OS_DRIVE}p"
    else
        >&2 echo "$0: unable to decide how to partition '${OS_DRIVE}'"
        exit 1
    fi
else
    >&2 echo "$0: no such drive exists"
    exit 1
fi

if [ "${PARTITION_LAYOUT}" = 'desktop' ]; then
    PARTITIONING_SCRIPT="$(pwd)/scripts/desktop-partitions.sh"
elif [ "${PARTITION_LAYOUT}" = 'rpi' ]; then
    PARTITIONING_SCRIPT="$(pwd)/scripts/raspberry-pi-partitions.sh"
elif [ "${PARTITION_LAYOUT}" = 'virt' ]; then
    PARTITIONING_SCRIPT="$(pwd)/scripts/virt-partitions.sh"
else
    >&2 echo "$0: invalid argument for 'disk partition layout'"
    >&2 echo "$0: possible values are 'desktop', 'rpi', 'virt'"
    exit 1
fi

# partition, format and mount
"${PARTITIONING_SCRIPT}"

# prepare installation
mkdir -p "${MOUNT_PATH}/etc/nixos"
nixos-generate-config --root "${MOUNT_PATH}"
cp -vR nixos-configuration/* "${MOUNT_PATH}/etc/nixos"

# all host-specific configuration
# - generate 'networking.hostId' for ZFS
# - enable Intel/AMD microcode loading if either CPU is detected
# - adding NVIDIA GPU support if it is detected
# - enabling KDE if the machine if $PARTITION_LAYOUT is either 'desktop'
# - enabling BSPWM if the machine if $PARTITION_LAYOUT is either 'virt'
# - enabling Podman containers if $MACHINE_HOSTNAME is 'reddish' (Raspberry Pi 4 Model B 8GB)
"$(pwd)/scripts/deviation.sh"

# wait for the user to verify the contents of '${MOUNT_PATH}/etc/nixos'
read WAIT_UNCONDITIONALLY

# install NixOS
nixos-install --no-root-password --root "${MOUNT_PATH}"

# very very initial setup for 'pratham'
cp "$(pwd)/scripts/chroot-as-pratham.sh" "${MOUNT_PATH}/home/pratham"
nixos-enter --root "${MOUNT_PATH}" -c 'sudo -i -u pratham bash /home/pratham/chroot-as-pratham.sh'
rm "${MOUNT_PATH}/home/pratham/chroot-as-pratham.sh"

# done!
sync; sync; sync; sync;
sleep 10
sync; sync; sync; sync;
umount -R "${MOUNT_PATH}"
