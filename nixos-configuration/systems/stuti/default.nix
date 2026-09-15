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
    etcMachineID = "f23f95475f594760b381d2ab29395d48";
    persistence.enable = true;
    socSupport.armSoc = "rk3588";
  };
}
