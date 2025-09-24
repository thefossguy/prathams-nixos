{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.nixGc;
in
{
  systemd.services."${serviceConfig.unitName}" = {
    before = serviceConfig.beforeUnits;
    wants = serviceConfig.wantedUnits;
  };
}
