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

  customOptions = {
    etcMachineID = "f2956c2de1d843e39fecf26613e95e4e";
    persistence.enable = true;
    socSupport.armSoc = "rpi4";
  };
}
