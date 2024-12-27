{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.scheduledReboots;
in
# Automatic/scheduled reboots should apply only to headless machines which I
# don't use more than once a week (servers) but want to keep them up-to-date.
lib.mkIf (config.customOptions.systemType == "server") {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        # we reboot every Sundays, forcing the NixOS system to use the latest installed kernel
        ${pkgs.systemd}/bin/systemctl reboot
      '';
    };
  };
}
