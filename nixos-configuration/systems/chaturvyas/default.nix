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

  customOptions.socSupport.armSoc = "rk3588";
  customOptions.localCaching.servesNixDerivations = true;
}
