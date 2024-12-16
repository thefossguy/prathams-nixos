{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf ((config.customOptions.socSupport.armSoc == "rpi4") || (config.customOptions.socSupport.armSoc == "rpi5")) {
  boot.kernelParams = [ "console=ttyS0,115200" ];
}
