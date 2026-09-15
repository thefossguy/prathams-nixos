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
    etcMachineID = "fc6c8bad92a048f09044b7a0ca98d523";
    persistence.enable = true;
  };
}
