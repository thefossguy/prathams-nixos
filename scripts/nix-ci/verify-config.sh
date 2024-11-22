#!/usr/bin/env bash

NIXOS_SYSTEMS=(
    '.#isoImages.aarch64-linux.nozfs'
    '.#isoImages.aarch64-linux.zfs'
    '.#isoImages.riscv64-linux.nozfs'
    '.#isoImages.riscv64-linux.zfs'
    '.#isoImages.x86_64-linux.nozfs'
    '.#isoImages.x86_64-linux.zfs'
    '.#nixosConfigurations.bheem'
    '.#nixosConfigurations.bhim'
    '.#nixosConfigurations.chaturvyas'
    '.#nixosConfigurations.flameboi'
    '.#nixosConfigurations.indra'
    '.#nixosConfigurations.madhav'
    '.#nixosConfigurations.mahadev'
    '.#nixosConfigurations.matsya'
    '.#nixosConfigurations.pawandev'
    '.#nixosConfigurations.raajan'
    '.#nixosConfigurations.reddish'
    '.#nixosConfigurations.sentinel'
    '.#nixosConfigurations.stuti'
    '.#nixosConfigurations.vaaman'
    '.#nixosConfigurations.vaayu'
)

if [[ -z "${1:-}" ]]; then
    exit 0
fi

for nixosSystem in "${NIXOS_SYSTEMS[@]}"; do
    echo -ne "${nixosSystem}.config.$1: "
    nix eval "${nixosSystem}.config.$1" 2>/dev/null
done
