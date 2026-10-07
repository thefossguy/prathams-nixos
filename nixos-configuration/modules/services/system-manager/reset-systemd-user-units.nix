{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.resetSystemdUserUnits;
in
{
  systemd = {
    services."${serviceConfig.unitName}" = {
      enable = true;
      wantedBy = serviceConfig.wantedByUnits;

      unitConfig = {
        RequiresMountsFor = "${config.customOptions.userHomeDir}";
        JobRunningTimeoutSec = "infinity";
        JobTimeoutSec = "infinity";
      };

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/true";
        ExecStop = "rm -rf ${config.customOptions.userHomeDir}/.config/systemd/user";
      };
    };
  };
}
