{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelModules = [ "panthor" ];
  hardware.bluetooth.enable = lib.mkForce false;

  customOptions = {
    displayServer.guiSession = "cosmic";
    socSupport.armSoc = "rk3588";
  };
}
