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
    etcMachineID = "fea08f2a25974e6c934b48f36b63d2ca";
    persistence.enable = true;
    socSupport.armSoc = "rpi5";
  };
}
