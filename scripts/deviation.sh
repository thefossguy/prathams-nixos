#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages bash findutils

set -x
NETWORKING_HOSTNAME="${1}"
PARTITION_LAYOUT_TYPE="${2}"
CUSTOM_HOST_CONFIG='/mnt/etc/nixos/host-specific-configuration.nix'
NETWORKING_HOSTID="$(head -c4 /dev/urandom | od -A none -t x4 | xargs)"
CPU_INFO="$(cat /proc/cpuinfo)"
GPU_INFO="$(lspci -vvv)"

# always make sure that the file exists because it is included in the master config
touch "${CUSTOM_HOST_CONFIG}"

cat << EOF > "${CUSTOM_HOST_CONFIG}"
{ config, pkgs, lib, ... }:

{
  networking = {
    hostId = "${NETWORKING_HOSTID}";
    hostName = "${NETWORKING_HOSTNAME}";
  };
EOF

if [[ "${CPU_INFO}" =~ "AuthenticAMD" ]]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  hardware.cpu.amd.updateMicrocode = true;
  boot.extraModprobeConfig = "options nested=1 kvm_amd";
EOF
elif [[ "${CPU_INFO}" =~ "GenuineIntel" ]]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  hardware.cpu.intel.updateMicrocode = true;
  boot.extraModprobeConfig = "options nested=1 kvm_intel";
EOF
fi

if [[ "${GPU_INFO}" =~ "VGA" && "${GPU_INFO}" =~ "NVIDIA" ]]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

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

if [[ "${PARTITION_LAYOUT_TYPE}" =~ "desktop" || "${PARTITION_LAYOUT_TYPE}" =~ "virt" ]]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  imports = [
    ./desktop-env/kde-plasma-wayland-configuration.nix
  ];
EOF
fi

if [[ "${NETWORKING_HOSTNAME}" =~ "reddish" ]]; then
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  boot.zfs.extraPools = [ "trayimurti" ];

  imports = [
    ./user-services/podman-master.nix
  ];
EOF
fi

echo '}' >> "${CUSTOM_HOST_CONFIG}"
