#!/usr/bin/env bash

date +%Y/%m/%d\ %H:%M:%S
set -xeuf -o pipefail

nix_flake_flags='--extra-experimental-features nix-command --extra-experimental-features flakes'
readonly nix_flake_flags

if [[ "$(id -u)" != '0' ]]; then
    echo 'ERROR: Please run this script as root'
    exit 1
fi

if ! ping -c 1 google.com > /dev/null; then
    echo 'ERROR: Not connected to the internet... exiting...'
    exit 1
fi

if [[ -z "${1:-}" || -z "${2:-}" ]]; then
    # shellcheck disable=SC2016
    echo 'ERROR: Insufficient arguments... $1:target_disk, $2:hostname'
    exit 1
else
    TARGET_DRIVE="$1"
    HOSTNAME="$2"
fi

if [ -b "${TARGET_DRIVE}" ]; then
    if echo "${TARGET_DRIVE}" | grep "sd\|vd" > /dev/null; then
        INTERMEDIATE_PART="${TARGET_DRIVE}"
    elif echo "${TARGET_DRIVE}" | grep "mmcblk\|nvme\|loop" > /dev/null; then
        INTERMEDIATE_PART="${TARGET_DRIVE}p"
    else
        echo "ERROR: Unable to decide how to partition '${TARGET_DRIVE}'"
        exit 1
    fi
else
    echo "ERROR: '${TARGET_DRIVE}' is not a block device"
    exit 1
fi

echo 'This may take some time on the first run.'
# shellcheck disable=SC2086
nix ${nix_flake_flags} flake update
# shellcheck disable=SC2086
nix ${nix_flake_flags} build --dry-run --verbose --trace-verbose --print-build-logs --show-trace .#nixosConfigurations."${HOSTNAME}".config.system.build.toplevel
# shellcheck disable=SC2086
if nix ${nix_flake_flags} eval .#nixosConfigurations."${HOSTNAME}".config.boot.initrd.supportedFilesystems.zfs 2>/dev/null; then
    echo 'ERROR: I do not yet know how to handle ZFS datasets. Exiting.'
    exit 2
fi

TARGET_DRIVE_SIZE_IN_BYTES="$(blockdev --getsize64 "${TARGET_DRIVE}")"
TARGET_DRIVE_SIZE_IN_GIB="$(( TARGET_DRIVE_SIZE_IN_BYTES / 1024 / 1024 /1024 ))"
if [[ "${TARGET_DRIVE_SIZE_IN_GIB}" -lt 32 ]]; then
    echo 'ERROR: Get a bigger disk'
    exit 1
elif [[ "${TARGET_DRIVE_SIZE_IN_GIB}" -lt 64 ]]; then
    ROOT_PART_SIZE=24
else
    BASE=1
    while [[ "${TARGET_DRIVE_SIZE_IN_GIB}" -gt "${BASE}" ]]; do
        BASE="$(( BASE * 2))"
    done
    ROOT_PART_SIZE=$(( BASE / 4 ))
fi

export HOSTNAME
export TARGET_DRIVE
export INTERMEDIATE_PART
export ROOT_PART_SIZE
export MOUNT_PATH='/mnt'

################################################################################
# installation actually starts here
################################################################################

# make sure that $MOUNT_PATH is empty
# otherwise, bad things happen
mount | grep " on ${MOUNT_PATH}" && umount --recursive --force "${MOUNT_PATH}"

# now we partition
./scripts/installation-scripts/partition-disk.sh

# finally, we install NixOS
TOTAL_MEM_IN_KIB="$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')"
TOTAL_MEM_IN_GIB="$(( TOTAL_MEM_IN_KIB / 1024 / 1024 ))"
MIN_MEMORY_IN_GIB='4'
if [[ "${TOTAL_MEM_IN_GIB}" -lt "${MIN_MEMORY_IN_GIB}" ]]; then
    echo "WARNING: Total memory is less than ${MIN_MEMORY_IN_GIB} GB. You might get an OOM-kill ... "
fi

nixos-install \
    --show-trace \
    --root ${MOUNT_PATH} \
    --no-root-password \
    --flake ".#${HOSTNAME}"

# very very initial setup for 'pratham'
# enable networking first
mount -o bind /etc/resolv.conf "${MOUNT_PATH}/etc/resolv.conf"
# shellcheck disable=SC2207
REAL_USER_LIST=( $(awk -F ':' '{print $6}' "${MOUNT_PATH}/etc/passwd" | grep '/home/' | awk -F '/' '{print $NF}') )
CHROOT_USER_SCRIPT='chroot-user-setup.sh'
for NIXOS_USER in "${REAL_USER_LIST[@]}"; do
    DESTINATION="/home/${NIXOS_USER}/${CHROOT_USER_SCRIPT}"
    cp "./scripts/installation-scripts/${CHROOT_USER_SCRIPT}" "${MOUNT_PATH}${DESTINATION}"
    nixos-enter --root "${MOUNT_PATH}" -c "su --login ${NIXOS_USER} --command 'bash ${DESTINATION}'"
    rm "${MOUNT_PATH}${DESTINATION}"
done

if [[ "$(dmidecode -s system-manufacturer)" == 'QEMU' ]]; then
    # if we're in a VM, at the very least, the flake.nix must be modified
    # so we copy the entire tree itself to the VM
    rm -rf "${MOUNT_PATH}/etc/nixos"
    cp -R "$(git rev-parse --show-toplevel)" "${MOUNT_PATH}/etc/nixos"
fi

# done!
sync; sync; sync; sync;
umount -vR "${MOUNT_PATH}"
