{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.nixGc;
in {
  systemd.services."${serviceConfig.unitName}" = {
    before = serviceConfig.beforeUnits;
  };
}
