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
    etcMachineID = "f6c39553a79a423e8255790a64a523a4";
    persistence.enable = true;
    socSupport.armSoc = "rk3588";
  };
}
