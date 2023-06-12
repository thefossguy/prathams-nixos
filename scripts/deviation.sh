#!/usr/bin/env bash

NETWORKING_HOSTNAME=$1
CUSTOM_HOST_CONFIG='/mnt/etc/nixos/host-specific-configuration.nix'
NETWORKING_HOSTID=$(head -c4 /dev/urandom | od -A none -t x4 | xargs)
CPU_INFO=$(cat /proc/cpuinfo)

# always make sure that the file exists because it is included in the master config
touch ${CUSTOM_HOST_CONFIG}

cat << EOF > ${CUSTOM_HOST_CONFIG}
{ config, pkgs, ... }:

{
  networking = {
    hostId = "${NETWORKING_HOSTID}";
    hostName = "${NETWORKING_HOSTNAME}";
  };
EOF

if [[ ${CPU_INFO} =~ "AuthenticAMD" ]]; then
    cat << EOF >> ${CUSTOM_HOST_CONFIG}

  hardware.cpu.amd.updateMicrocode = true;
  boot.extraModprobeConfig = "options nested=1 kvm_amd";
EOF
elif [[ ${CPU_INFO} =~ "GenuineIntel" ]]; then
    cat << EOF >> ${CUSTOM_HOST_CONFIG}

  hardware.cpu.intel.updateMicrocode = true;
  boot.extraModprobeConfig = "options nested=1 kvm_intel";
EOF
fi

if [[ ${NETWORKING_HOSTNAME} == "flameboi" || ${NETWORKING_HOSTNAME} =~ "vm" || ${NETWORKING_HOSTNAME} =~ "virt" ]]; then
    cat << EOF >> ${CUSTOM_HOST_CONFIG}

  imports = [
    # desktop stuff
    ./desktop-configuration.nix
  ];
EOF
fi

echo '}' >> ${CUSTOM_HOST_CONFIG}
