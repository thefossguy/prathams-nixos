{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "flatpak-manage" = {
        Unit = {
        };
        Timer = {
          OnBootSec = "now";
          OnCalendar = "Mon *-*-* 04:00:00";
          Unit = "flatpak-manage.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
    systemd.user.services = {
      "flatpak-manage" = {
        Unit = {
          Description = "Manage flatpaks on system";
        };
        Service = {
          ExecStart = "${pkgs.bash}/bin/bash $HOME/.local/scripts/other-common-scripts/flatpak-manage.sh";
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
