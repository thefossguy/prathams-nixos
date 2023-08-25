#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash gnutar perl unzip wget

set -x
TMP_FIRMWARE_DIR="$(pwd)/rpi-firmware"
TMP_OUT_DIR="$(pwd)/out"
RPI4_EFI_FIRMWARE_TAG='v1.35'
RPI_VNDR_FIRMWARE_TAG='1.20230405'
RPI4_EFI_FIRMWARE_FILE="${TMP_FIRMWARE_DIR}/RPi4_UEFI_Firmware_${RPI4_EFI_FIRMWARE_TAG}.zip"
RPI_VNDR_FIRMWARE_FILE="${TMP_FIRMWARE_DIR}/${RPI_VNDR_FIRMWARE_TAG}.tar.gz"
RPI4_EFI_FIRMWARE_DIR="${TMP_FIRMWARE_DIR}/rpi-${RPI4_EFI_FIRMWARE_TAG}"
RPI_VNDR_FIRMWARE_DIR="${TMP_FIRMWARE_DIR}/firmware-${RPI_VNDR_FIRMWARE_TAG}"
RPI4_EFI_FIRMWARE_HASH='4c6f73a0af93d545bf09e40c99c581d01403bb09af84d5434cb970c7be66a1251c1ceebd317b1aa411a8b733f19abc957086c3b169b8c1dc72b6ff4bd601658d'
RPI_VNDR_FIRMWARE_HASH='ddc9baeba4e2e442bfe41e427c7ecdd38ee6d44ac4e7c297ae7d5a6c64b0aa1a81206929baeb9aceb74de6f96707b30040e82450ef4f01a78b958299c72e3857'

[ -d "${TMP_FIRMWARE_DIR}" ] || mkdir "${TMP_FIRMWARE_DIR}"
[ -d "${TMP_OUT_DIR}" ] && rm -rf "${TMP_OUT_DIR}"
mkdir "${TMP_OUT_DIR}"

while ! sha512sum "${RPI4_EFI_FIRMWARE_FILE}" | grep "${RPI4_EFI_FIRMWARE_HASH}"; do
    rm -f "${RPI4_EFI_FIRMWARE_FILE}"
    wget "https://github.com/pftf/RPi4/releases/download/${RPI4_EFI_FIRMWARE_TAG}/RPi4_UEFI_Firmware_${RPI4_EFI_FIRMWARE_TAG}.zip" --output-document "${RPI4_EFI_FIRMWARE_FILE}" || exit 1
done

while ! sha512sum "${RPI_VNDR_FIRMWARE_FILE}" | grep "${RPI_VNDR_FIRMWARE_HASH}"; do
    rm -f "${RPI_VNDR_FIRMWARE_FILE}"
    wget "https://github.com/raspberrypi/firmware/archive/refs/tags/${RPI_VNDR_FIRMWARE_TAG}.tar.gz" --output-document "${RPI_VNDR_FIRMWARE_FILE}" || exit 1
done

rm -rf "${RPI4_EFI_FIRMWARE_DIR}"
rm -rf "${RPI_VNDR_FIRMWARE_DIR}"

unzip "${RPI4_EFI_FIRMWARE_FILE}" -d "${RPI4_EFI_FIRMWARE_DIR}" || exit 1
tar -xvf "${RPI_VNDR_FIRMWARE_FILE}" -C "${TMP_FIRMWARE_DIR}" || exit 1

cp -rf "${RPI4_EFI_FIRMWARE_DIR}"/*      "${TMP_OUT_DIR}/"
cp -rf "${RPI_VNDR_FIRMWARE_DIR}"/boot/* "${TMP_OUT_DIR}/"

rm -vf "${TMP_OUT_DIR}"/*kernel*
rm -vf "${TMP_OUT_DIR}"/Readme.md
