#!/usr/bin/env nix-shell
#!nix-shell -i bash --packages

# not using 'set -u' because 'CPU_VENDOR' **will** be empty on non-x86_64 systems
set -xef -o pipefail

# always make sure that the file exists because it is included in the master config
touch "${CUSTOM_HOST_CONFIG}"
IMPORT_MODULES=('./zfs-configuration.nix')

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
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModprobeConfig = "options kvm_amd nested=1";
EOF
elif [ "${CPU_VENDOR}" = 'Intel' ]; then
    cat << EOF > "${CUSTOM_HOST_CONFIG}"

    hardware.cpu.intel.updateMicrocode = true;
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModprobeConfig = "options kvm_intel nested=1";
EOF
fi

if [ "${PARTITION_LAYOUT}" = 'desktop' ]; then
    IMPORT_MODULES+=('./desktop-env/kde-plasma-wayland-configuration.nix')

    # add GPU drivers only if user selects a DE/WM
    if [ "${OSS_GPU_DRIVERS}" = 'true' ]; then
        if [ "${GPU_AMD}" = 'true' ]; then
            IMPORT_MODULES+=('./desktop-env/gpu/amd-gpu.nix')
        fi
        if [ "${GPU_INTEL}" = 'true' ]; then
            IMPORT_MODULES+=('./desktop-env/gpu/intel-gpu.nix')
        fi
    elif [ "${OSS_GPU_DRIVERS}" = 'true' ]; then
        # if an NVIDIA GPU is detected, install only NVIDIA drivers such that
        # another GPU vendor's drivers aren't loaded and cause headache
        IMPORT_MODULES+=('./desktop-env/gpu/nvidia-gpu.nix')
    fi
fi

if [ "${MACHINE_HOSTNAME}" = 'reddish' ]; then
    IMPORT_MODULES+=('./user-services/podman/podman-master.nix')
fi

if [ "${BATTERY_POWERED_DEVICE}" = 'true' ]; then
    IMPORT_MODULES+=('./battery-and-power-management.nix')
fi

cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = ${CAN_TOUCH_EFI_VARS};

  #boot.tmp.useTmpfs = true; # mount the tmpfs on /tmp during boot
  #boot.tmp.tmpfsSize = "10%";

  #swapDevices = [{
  #  device = "/var/lib/swapfile";
  #  size = "1024 * 2";
  #}];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
EOF

cat << EOF >> "${CUSTOM_HOST_CONFIG}"

  imports = [
EOF

for MODULE in "${IMPORT_MODULES[@]}"; do
    cat << EOF >> "${CUSTOM_HOST_CONFIG}"
    ${MODULE}
EOF
done

cat << EOF >> "${CUSTOM_HOST_CONFIG}"
  ];
}
EOF
