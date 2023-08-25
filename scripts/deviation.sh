#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash

set -x

# always make sure that the file exists because it is included in the master config
touch "${CUSTOM_HOST_CONFIG}"

# setup hostname and hostid
cat << EOF > "${CUSTOM_HOST_CONFIG}"
{ config, pkgs, lib, ... }:

{
  networking = {
    hostId = "${NETWORKING_HOSTID}";
    hostName = "${MACHINE_HOSTNAME}";
  };
EOF

if [ "${CPU_VENDOR}" = 'AMD' ]; then
    cat << EOF > "${CUSTOM_HOST_CONFIG}"

    hardware.cpu.amd.updateMicrocode = true;
    boot.extraModprobeConfig = "options nested=1 kvm_amd";
EOF
elif [ "${CPU_VENDOR}" = 'Intel' ]; then
    cat << EOF > "${CUSTOM_HOST_CONFIG}"

    hardware.cpu.intel.updateMicrocode = true;
    boot.extraModprobeConfig = "options nested=1 kvm_intel";
EOF
fi

if [ "${GPU_VENDOR}" = 'NVIDIA' ]; then
    cat << EOF > "${CUSTOM_HOST_CONFIG}"

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
    ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
EOF
fi

if [ "${PARTITION_LAYOUT}" = 'desktop' ]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  imports = [
    ./desktop-env/kde-plasma-wayland-configuration.nix
  ];
EOF
elif [ "${PARTITION_LAYOUT}" = 'virt' ]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  imports = [
    ./desktop-env/bspwm-x11-configuration.nix
  ];
EOF
fi

if [ "${MACHINE_HOSTNAME}" = 'reddish' ]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  boot.zfs.extraPools = [ "trayimurti" ];

  imports = [
    ./user-services/podman-master.nix
  ];
EOF
fi

echo '}' >> "${CUSTOM_HOST_CONFIG}"
