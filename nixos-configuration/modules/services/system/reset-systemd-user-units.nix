{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.resetSystemdUserUnits;
  systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
in {
  systemd = {
    services."${serviceConfig.unitName}" = {
      enable = true;
      before = serviceConfig.beforeUnits;
      requiredBy = serviceConfig.requiredByUnits;

      unitConfig = {
        RequiresMountsFor = "/home/${systemUserUsername}";
      };

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "rm -rf /home/${systemUserUsername}/.config/systemd/user";
    };
  };
}
