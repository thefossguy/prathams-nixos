#!/usr/bin/env bash

set -eu -o pipefail

if [ "$(uname -s)" != 'Linux' ]; then
    echo 'What operating system even is this?'
    exit 1
fi

set -x
time nom build --show-trace ".#isos.$(uname -m)"

for resultISO in $(basename result/iso/nixos-*-linux.iso); do
    if [ ! -f "${resultISO}" ]; then
        cp result/iso/"${resultISO}" .
    fi
    if [ ! -f "${resultISO}.sha512" ]; then
        sha512sum "${resultISO}" | awk '{print $1}' 1> "${resultISO}.sha512"
    fi
    chown "${USER}:${USER}" "${resultISO}"
    chmod 644 "${resultISO}"
done
