{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  hardware.bluetooth.enable = lib.mkForce false;

  customOptions = {
    displayServer.guiSession = "cosmic";
    socSupport.armSoc = "rk3588";
  };
}
