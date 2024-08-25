{ pkgs, ... }:

{
  boot = {
    kernelParams = [ "console=ttyS0,115200" ];

    loader.systemd-boot.extraInstallCommands = ''

      # ----[ cut ]----
      # RPi Specific script starts here
      set -x
      ${pkgs.rsync}/bin/rsync --quiet --no-motd --checksum --recursive --progress --stats ${pkgs.rpiUBootAndFirmware}/ /boot/
    '';
  };

  nixpkgs.overlays = [
    (final: prev: {
      rpiUBootAndFirmware = prev.stdenvNoCC.mkDerivation {
        name = "rpiUBootAndFirmware";
        dontUnpack = true;
        buildInputs = [ final.ubootRaspberryPiGeneric_64bit ];

        buildPhase = ''
          set -x

          mkdir $out
          cp -r ${prev.raspberrypifw}/share/raspberrypi/boot/* $out
          rm -vf $out/kernel*.img
          cp -r ${final.ubootRaspberryPiGeneric_64bit}/u-boot.bin $out/u-boot-generic-arm64.bin

          cat << EOF > $out/config.txt
          # http://rptl.io/configtxt
          arm_64bit=1
          enable_uart=1
          kernel=u-boot-generic-arm64.bin
          disable_fw_kms_setup=1
          disable_splash=0
          display_auto_detect=1
          dtoverlay=vc4-kms-v3d
          dtparam=audio=on
          enable_tvout=0
          max_framebuffers=2

          [pi4]
          arm_boost=1
          hdmi_enable_4kp60=0 # increases power consumption and no longer needed

          [cm4]
          otg_mode=1

          [pi5]
          dtparam=uart0_console # enables UART over the "old" GPIO pins (14 and 15)
          EOF

          set +x
        '';
      };

      ubootRaspberryPiGeneric_64bit = prev.buildUBoot {
        defconfig = "rpi_arm64_defconfig";
        extraMeta.platforms = [ "aarch64-linux" ];
        filesToInstall = [ "u-boot.bin" ];
      };
    })
  ];
}
