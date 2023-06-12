#!/usr/bin/env bash

EFI_FIRM_TAG='v1.35'
RPI_FIRM_TAG='1.20230405'
EFI_FIRM_FILE="${RPI_FIRM_TAG}.tar.gz"
RPI_FIRM_FILE="RPi4_UEFI_Firmware_${EFI_FIRM_TAG}.zip"
RPI_FIRM_DIR="firmware-${RPI_FIRM_TAG}"
EFI_FIRM_DIR='RPi4_UEFI_Firmware'
EFI_FIRM_HASH='4c6f73a0af93d545bf09e40c99c581d01403bb09af84d5434cb970c7be66a1251c1ceebd317b1aa411a8b733f19abc957086c3b169b8c1dc72b6ff4bd601658d'
RPI_FIRM_HASH='ddc9baeba4e2e442bfe41e427c7ecdd38ee6d44ac4e7c297ae7d5a6c64b0aa1a81206929baeb9aceb74de6f96707b30040e82450ef4f01a78b958299c72e3857'

if [[ ! -d "rpi-firmware/${EFI_FIRM_DIR}" && ! -d "rpi-firmware/${EFI_FIRM_DIR}" ]]; then
    mkdir rpi-firmware
    pushd rpi-firmware

    # get firmware
    echo "Downloading firmware for Raspberry Pi..."
    wget "https://github.com/raspberrypi/firmware/archive/refs/tags/${RPI_FIRM_TAG}.tar.gz" 2> /dev/null
    wget "https://github.com/pftf/RPi4/releases/download/${EFI_FIRM_TAG}/RPi4_UEFI_Firmware_${EFI_FIRM_TAG}.zip" 2> /dev/null

    # verify
    echo "${RPI_FIRM_HASH} *${RPI_FIRM_TAG}.tar.gz" | shasum --check || exit 1
    echo "${EFI_FIRM_HASH} *RPi4_UEFI_Firmware_${EFI_FIRM_TAG}.zip" | shasum --check || exit 1

    # extract
    tar xf ${RPI_FIRM_TAG}.tar.gz
    unzip RPi4_UEFI_Firmware_${EFI_FIRM_TAG}.zip -d RPi4_UEFI_Firmware

    popd
fi

# prep
[[ -d out ]] && rm -rf out
mkdir out

# copy
cp -r rpi-firmware/firmware-${RPI_FIRM_TAG}/boot/* out/
cp -r rpi-firmware/RPi4_UEFI_Firmware/* out/

# remove other stuff
rm -vf out/*kernel*
rm -vf out/Readme.md
