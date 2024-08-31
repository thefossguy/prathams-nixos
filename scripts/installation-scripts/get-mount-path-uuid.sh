#!/usr/bin/env bash

set -euf -o pipefail

if [[ -z "${MOUNT_PATH:-}" ]]; then
    # shellcheck disable=SC2016
    echo 'ERROR: $MOUNT_PATH is undefined'
    exit 1
fi

if [[ -z "${HOSTNAME:-}" ]]; then
    # shellcheck disable=SC2016
    echo 'ERROR: $HOSTNAME is undefined'
    exit 1
fi

BOOT_MOUNT_PATH='fileSystems."/boot"'
ROOT_MOUNT_PATH='fileSystems."/"'
HOME_MOUNT_PATH='fileSystems."/home"'
VARL_MOUNT_PATH='fileSystems."/var"'

# i know `case-esac` but that's ugly
if [[ "${MOUNT_PATH}" == 'boot' ]]; then
    MOUNT_PATH="${BOOT_MOUNT_PATH}"
elif [[ "${MOUNT_PATH}" == 'root' ]]; then
    MOUNT_PATH="${ROOT_MOUNT_PATH}"
elif [[ "${MOUNT_PATH}" == 'home' ]]; then
    MOUNT_PATH="${HOME_MOUNT_PATH}"
elif [[ "${MOUNT_PATH}" == 'var' ]]; then
    MOUNT_PATH="${VARL_MOUNT_PATH}"
else
    # shellcheck disable=SC2016
    echo 'ERROR: invalid $MOUNT_PATH; values are: boot, root, home, var'
    exit 1
fi

TARGET_FILE="nixos-configuration/systems/${HOSTNAME}/default.nix"
if [[ -f "${TARGET_FILE}" ]]; then
    grep -A 1 "${MOUNT_PATH}" "${TARGET_FILE}" | tail -n 1 | \
      grep 'device = "/dev/disk/by-uuid/' | \
      rev | cut -c 3- | rev | \
      sed -e 's@/@ @g' | \
      awk '{print $NF}'
else
    # shellcheck disable=SC2016
    echo 'ERROR: No file found for $HOSTNAME'
    exit 1
fi

