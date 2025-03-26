{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf ((config.customOptions.socSupport.armSoc == "rpi4") || (config.customOptions.socSupport.armSoc == "rpi5")) {
  boot.kernelParams = [ "console=ttyAMA0,115200" ];
}
