{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    socSupport.armSoc = "rk3588";
    localCaching.servesNixDerivations = true;
    wireguardOptions.enabledVPNs = [
      "wg0x0"
      "wg0x1"
    ];
  };
}
