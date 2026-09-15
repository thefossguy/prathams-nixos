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
    etcMachineID = "f262995281654a85a8fa2fbae3b997d1";
    persistence.enable = true;
    socSupport.armSoc = "rk3588";
  };
}
