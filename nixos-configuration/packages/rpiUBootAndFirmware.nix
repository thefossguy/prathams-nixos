self: super: {
  rpiUBootAndFirmware = super.stdenvNoCC.mkDerivation {
    name = "rpiUBootAndFirmware";
    dontUnpack = true;
    buildInputs = with super; [
      raspberrypifw
      ubootRaspberryPi3_64bit
      ubootRaspberryPi4_64bit
    ];

    buildPhase = ''
      set -x

      mkdir $out
      cp -r ${super.raspberrypifw}/share/raspberrypi/boot/* $out
      rm -f $out/kernel*.img

      cp ${super.ubootRaspberryPi3_64bit}/u-boot.bin $out/uboot-rpi-3.bin
      cp ${super.ubootRaspberryPi4_64bit}/u-boot.bin $out/uboot-rpi-4.bin
      #cp ''${super.ubootRaspberryPi5_64bit}/u-boot.bin $out/uboot-rpi-5.bin

      cat << EOF > $out/config.txt
      [pi3]
      kernel=uboot-rpi-3.bin

      [pi4]
      kernel=uboot-rpi-4.bin
      arm_boost=1
      disable_fw_kms_setup=1
      enable_tvout=0
      hdmi_enable_4kp60=1 # increases power consumption but at least I can see things clearly

      [pi5]
      kernel=uboot-rpi-5.bin
      enable_tvout=0

      [all]
      arm_64bit=1
      enable_uart=1
      disable_splash=0
      EOF

      set +x
    '';
  };
}
