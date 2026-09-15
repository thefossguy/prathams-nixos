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
    etcMachineID = "f022e3cbc18946ae8b1a237bba4b50da";
    persistence.enable = true;
  };
}
