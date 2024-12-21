{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.resetSystemdUserUnits;
  systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
in {
  systemd = {
    services."${serviceConfig.unitName}" = {
      enable = true;
      wantedBy = serviceConfig.wantedBy;

      unitConfig = {
        RequiresMountsFor = "/home /home/${systemUserUsername}";
      };

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        RemainAfterExit = true;
        JobTimeoutSec = "infinity";
        JobRunningTimeoutSec = "infinity";
        ExecStart = "${pkgs.coreutils}/bin/true";
        ExecStop = "rm -rf /home/${systemUserUsername}/.config/systemd/user";
      };
    };
  };
}
