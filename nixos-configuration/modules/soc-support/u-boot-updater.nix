{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:
let
  ubootPackages = let unstablePkgs = pkgsChannels.unstable; in {
    sentinel   = unstablePkgs.ubootRaspberryPi4_64bit;
    reddish    = unstablePkgs.ubootRaspberryPi4_64bit;
    mahadev    = unstablePkgs.ubootRock5ModelB;
    pawandev   = unstablePkgs.ubootOrangePi5;
    stuti      = unstablePkgs.ubootNanoPCT6;
    chaturvyas = unstablePkgs.ubootCM3588NAS;
    raajan     = unstablePkgs.ubootRaspberryPi5;
    vaaman     = unstablePkgs.ubootVisionFive2;
    vaayu      = unstablePkgs.ubootVisionFive2;
  };
  selectedUbootPackage = ubootPackages."${config.networking.hostName}";

  ddFlags = "conv=sync";

  isRk3588 = (config.customOptions.socSupport.armSoc == "rk3588");
  rk3588UbootUpgradeScript = ''
    if [[ '${isRk3588}' == 'true' ]]; then
        if [[ -c /dev/mtd0 ]]; then
            if ! grep --text --null --quiet 'U-Boot SPL ${selectedUbootPackage.version}' /dev/mtd0; then
                dd ${ddFlags} if=${selectedUbootPackage.outPath}/u-boot-rockchip-spi.bin of=/dev/mtd0
            fi
        fi

        EMMC_DEVICES=('/dev/mmcblk0' '/dev/mmcblk1')
        for MMC_DEV in "''${EMMC_DEVICES[@]}"; do
            if [[ -b "''${MMC_DEV}" ]]; then
                if fdisk -l "''${MMC_DEV}" | grep 'EFI System' | grep -q 65536; then
                    if ! grep --text --null --quiet 'U-Boot SPL ${selectedUbootPackage.version}' "''${MMC_DEV}"; then
                        dd ${ddFlags} if=${selectedUbootPackage.outPath}/u-boot-rockchip.bin bs=512 seek=64 of="''${MMC_DEV}"
                    fi
                fi
            fi
        done
    fi
  '';

  isRaspberryPi = ((config.customOptions.socSupport.armSoc == "rpi4") || (config.customOptions.socSupport.armSoc == "rpi5"));
  rpiUbootUpgradeScript = ''
    if [[ '${isRaspberryPi}' == 'true' ]]; then
        # Will only update if versions differ, so no need to check for version
        # and worry about flash degradation with write cycles.
        ${pkgs.rsync}/bin/rsync --quiet --no-motd --checksum --recursive --progress --stats ${pkgs.rpiUbootAndFirmware}/ /boot/
    fi
  '';
in {
  boot = {
    kernelParams = [
      "custom_options.uboot_version=${selectedUbootPackage.version}"
    ];

    loader.systemd-boot.extraInstallCommands = ''
      # ----[ cut ]----
      # U-Boot upgrade script starts here
      set -x

      if grep -q 'custom_options.uboot_version=${selectedUbootPackage.version}' /proc/cmdline; then
          # Running the latest version of U-Boot provided by Nixpkgs. Do nothing.
          exit 0
      fi

      ${rk3588UbootUpgradeScript}

      ${rpiUbootUpgradeScript}
    '';
  };
}
