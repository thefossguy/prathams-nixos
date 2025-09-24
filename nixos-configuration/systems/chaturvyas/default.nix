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
    localCaching.servesNixDerivations = true;
    socSupport.armSoc = "rk3588";
    wireguardOptions.enabledVPNs = [
      "wg0x0"
      "wg0x1"
    ];
  };
}
