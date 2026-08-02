{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.localCaching.servesNixDerivations {
}
