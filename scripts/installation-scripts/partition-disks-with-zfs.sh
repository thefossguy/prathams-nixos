#!/usr/bin/env bash

set -xeuf -o pipefail

## **SET "LBA FORMAT" FIRST**
## 1. Check what LBA Format is being used
#sudo nvme id-ns -H </dev/nvme> | grep 'LBA Format'
## 2. Find the "best" format
#sudo nvme id-ns -H </dev/nvme> | grep 'LBA Format' | grep 'Best'
## 2. Use the "best" format
#sudo nvme format --lbaf=<the "best" LBA format> --force </dev/nvme>

# do this first to fail early if this `exit 1`s
BOOT_UUID="$(MOUNT_PATH=boot ./scripts/installation-scripts/get-mount-path-uuid.sh)"
cat << EOF | fdisk --wipe always "${TARGET_DRIVE}"
g
n
1

+1G
w
EOF
sync; sync; sync; sync;
hdparm -z "${TARGET_DRIVE}"
BOOT_PART="${INTERMEDIATE_PART}1"
mkfs.fat -F 32 -n nixboot "${BOOT_PART}" -i "${BOOT_UUID//-/}"
parted -s "${TARGET_DRIVE}" -- set 1 esp on
BOOT_PART="/dev/disk/by-uuid/${BOOT_UUID}"

zpoolName="${HOSTNAME}-zpool"
# get the options specified in `zpool create -o` with `man 7 zpoolprops`
# get the options specified in `zpool create -O` with `man 7 zfsprops`
zpoolCreate="zpool create -o ashift=12 -o autotrim=off -o compatibility=off -o listsnapshots=on -O atime=off -O checksum=fletcher4 -O compression=zstd-fast -O primarycache=none -O relatime=off -O sync=always -O xattr=sa -m none ${zpoolName}"
export zpoolCreate

if [[ "${HOSTNAME}" == 'chaturvyas' ]]; then
    ${zpoolCreate} raidz1 nvme0n1 nvme1n1 nvme2n1 nvme3n1
else
    echo 'Handle the **ZPOOL creation** yourself.'
    echo 'Hint: `echo $zpoolCreate`.'
    bash
fi

ZPOOL_ROOTFS_SIZE="$(( $(( $(zpool list -H -o size -p) / $(( 1024 * 1024 * 1024 )) )) / 4 ))G"
zfs create -o mountpoint=/     -o recordsize=64K -o refreservation="${ZPOOL_ROOTFS_SIZE}" -u "${zpoolName}/root"
zfs create -o mountpoint=/home -o recordsize=64K -u "${zpoolName}/home"
zfs create -o mountpoint=/var  -o recordsize=64K -o checksum=off -o compression=zstd-19 -o snapshot_limit=0 -o redundant_metadata=none -o refquota=6G -u "${zpoolName}/var"
zpool export "${zpoolName}" && zpool import "${zpoolName}" -R "${MOUNT_PATH}"
mount -o async,lazytime,relatime --mkdir "${BOOT_PART}" "${MOUNT_PATH}/boot"
