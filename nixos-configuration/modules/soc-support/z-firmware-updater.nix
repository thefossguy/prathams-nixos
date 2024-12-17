{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  ubootPackages = {
    # TODO: Add support for `vaaman` and `vaayu` once nixpkgs has RISC-V support.
    chaturvyas = pkgs.ubootCM3588NAS;
    mahadev = pkgs.ubootRock5ModelB;
    pawandev = pkgs.ubootOrangePi5;
    raajan = pkgs.rpiUbootAndFirmware;
    reddish = pkgs.rpiUbootAndFirmware;
    sentinel = pkgs.rpiUbootAndFirmware;
    stuti = pkgs.ubootNanoPCT6;
  };
  selectedUbootPackage = ubootPackages."${config.networking.hostName}" or null;
  ddFlags = "conv=sync status=progress";
  appendedPath = import ../../../functions/append-to-path.nix {
    packages = with pkgs; [
      coreutils-full
      gnugrep
      util-linux
    ];
  };

  rpiUpdateScript = lib.strings.optionalString ((config.customOptions.socSupport.armSoc == "rpi4") || (config.customOptions.socSupport.armSoc == "rpi5")) ''
    ${pkgs.rsync}/bin/rsync --quiet --no-motd --checksum --recursive --progress --stats ${selectedUbootPackage.outPath}/ /boot/
  '';

  rk3588UpdateScript = lib.strings.optionalString (config.customOptions.socSupport.armSoc == "rk3588") ''
    if [[ "$(cat /proc/sys/kernel/hostname)" != '${config.networking.hostName}' ]]; then
        echo 'Refusing to proceed further because'
        echo '1. The NixOS System is being built in a CI and updating U-Boot'
        echo '   will actually cause damage.'
        echo '2. NixOS is being installed and I cannot guarantee (without'
        echo '   overly complicating this script) that the target machine is'
        echo '   the same as the host machine.'
        exit 0
    fi

    UBOOT_FLASHED=0
    if [[ -c /dev/mtd0 ]]; then
        dd ${ddFlags} of=/dev/mtd0 if=${selectedUbootPackage.outPath}/u-boot-rockchip-spi.bin
        UBOOT_FLASHED=1
    fi

    EMMC_DEVICES=( '/dev/mmcblk0' '/dev/mmcblk1' )
    for MMC_DEV in "''${EMMC_DEVICES[@]}"; do
        if [[ -b "''${MMC_DEV}" ]]; then
            if fdisk -l "''${MMC_DEV}" | grep 'EFI System' | grep -q 131072; then
                dd ${ddFlags} bs=512 seek=64 of="''${MMC_DEV}" if=${selectedUbootPackage.outPath}/u-boot-rockchip.bin
                UBOOT_FLASHED=1
            fi
        fi
    done

    if [[ "''${UBOOT_FLASHED}" -eq 0 ]]; then
        echo "Could not update U-Boot. Found no suitable media to flash."
        exit 1
    fi
  '';
in

lib.mkIf config.customOptions.socSupport.handleFirmwareUpdates {
  boot = {
    kernelParams = [
      "custom_options.uboot_version=${selectedUbootPackage.version}"
    ];

    loader.systemd-boot.extraInstallCommands = ''
      # ----[ cut ]----
      # U-Boot upgrade script starts here
      set -x

      ${appendedPath}
      export PATH
      ${rpiUpdateScript}
      ${rk3588UpdateScript}
    '';
  };
}
