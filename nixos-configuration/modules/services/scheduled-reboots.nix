{ config, lib, pkgs, ... }:

{
  systemd = lib.mkIf (config.custom-options.isNixosServer or false) {
    timers."scheduled-reboots" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "scheduled-reboots";
        OnCalendar = "Sun *-*-* 00:00:00";
      };
    };

    services."scheduled-reboots" = {
      enable = true;
      requires = [ "custom-nixos-upgrade.service" ];

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
