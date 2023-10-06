#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash

set -xe

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
    ./user-services/podman/podman-master.nix
  ];
EOF
fi

if [ -n "${SPECIAL_IP_ADDR}" ]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  networking = {
    interfaces = {
      enP4p1s0.ipv4.addresses = [{
        address = "10.0.0.169";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "10.0.0.1";
      interface = "enP4p1s0";
    };
  };
EOF
fi

if [ ${TOTAL_MEM_GIB} -gt 30 ]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  boot.tmp = {
    useTmpfs = true; # mount a tmpfs on /tmp during boot
    tmpfsSize = "50%";
  };
EOF
fi

echo '}' >> "${CUSTOM_HOST_CONFIG}"
