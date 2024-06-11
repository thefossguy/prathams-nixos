{ pkgs, ... }:

let
  rpiUBootAndFirmware = pkgs.stdenvNoCC.mkDerivation {
    name = "rpiUBootAndFirmware";
    dontUnpack = true;
    buildInputs = [ ubootRaspberryPiGeneric_64bit ];

    buildPhase = ''
      set -x

      mkdir $out
      cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* $out
      rm -vf $out/kernel*.img
      cp -r ${ubootRaspberryPiGeneric_64bit}/u-boot.bin $out/u-boot-generic-arm64.bin

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
      hdmi_enable_4kp60=1 # increases power consumption but at least I can see things clearly

      [cm4]
      otg_mode=1

      [pi5]
      dtparam=uart0_console
      EOF

      set +x
    '';
  };

  ubootRaspberryPiGeneric_64bit = pkgs.buildUBoot rec {
    defconfig = "rpi_arm64_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["u-boot.bin"];

    version = "2024.07-rc4";
    src = pkgs.fetchurl {
      url = "https://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
      hash = "sha256-jTaz/QtH/pP8A6uyWqwsJrfCob8rHHRniMD8SvaHhsU=";
    };
  };
in

{
  boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
  boot.kernelParams = [ "console=ttyS1,115200n8" ];

  environment.systemPackages = [ rpiUBootAndFirmware ];
}
