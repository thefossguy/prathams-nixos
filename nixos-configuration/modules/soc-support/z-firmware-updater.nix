{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  updateUbootTfgConfig =
    {
      chaturvyas = {
        board = "cm3588";
        ubootPath = pkgs.ubootCM3588NAS;
      };

      mahadev = {
        board = "rock-5-model-b";
        ubootPath = pkgs.ubootRock5ModelB;
      };

      pawandev = {
        board = "orange-pi-5";
        ubootPath = pkgs.ubootOrangePi5;
      };

      raajan = {
        board = "raspberry-pi-5-model-b";
        ubootPath = pkgs.rpiUbootAndFirmware;
      };

      reddish = {
        board = "raspberry-pi-4-model-b";
        ubootPath = pkgs.rpiUbootAndFirmware;
      };

      sentinel = {
        board = "raspberry-pi-4-model-b";
        ubootPath = pkgs.rpiUbootAndFirmware;
      };

      stuti = {
        board = "nanopc-t6";
        ubootPath = pkgs.ubootNanoPCT6;
      };
    }
    ."${config.networking.hostName}" or null;
in

lib.mkIf config.customOptions.socSupport.handleFirmwareUpdates {
  boot.loader.systemd-boot.extraInstallCommands = ''
    #!/usr/bin/env bash

    if [[ "$(cat /proc/sys/kernel/hostname)" != '${config.networking.hostName}' ]]; then
        echo 'Refusing to proceed further because'
        echo '1. The NixOS System is being built in a CI and updating U-Boot'
        echo '   will actually cause damage.'
        echo '2. NixOS is being installed and I cannot guarantee (without'
        echo '   overly complicating this script) that the target machine is'
        echo '   the same as the host machine.'
        exit 0
    fi

    ${lib.getExe pkgs.update-uboot-tfg} --board ${updateUbootTfgConfig.board} --uboot-path ${updateUbootTfgConfig.ubootPath} --uboot-version ${updateUbootTfgConfig.ubootPath.version}
  '';
}
