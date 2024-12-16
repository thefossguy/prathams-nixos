#!/usr/bin/env bash
set -xeuf -o pipefail

PLATFORM_KERNEL="$(uname -s | awk '{print tolower($0)}')"
PLATFORM_ARCH="$(uname -m)"
if [[ "${PLATFORM_ARCH}" == 'arm64' ]]; then
    PLATFORM_ARCH='aarch64'
fi
NIX_SYSTEM="${PLATFORM_ARCH}-${PLATFORM_KERNEL}"

git pull
nix flake update
nix build .#homeConfigurations."${NIX_SYSTEM}"."${LOGNAME}".activationPackage
set +x
./result/activate
