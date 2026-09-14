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
    persistence.enable = true;
    socSupport.armSoc = "rk3588";
  };
}
