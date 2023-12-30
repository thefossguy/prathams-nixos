{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "nixos-config-pull" = {
        Unit = {
        };
        Timer = {
          OnCalendar = "*-*-* 23:00:00";
          Unit = "nixos-config-pull.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
    systemd.user.services = {
      "nixos-config-pull" = {
        Unit = {
          Description = "Pull NixOS configuration";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash $HOME/.local/scripts/nixos/nixos-config-pull.sh";
          Environment = [ "\"PATH=${pkgs.git}/bin:${pkgs.openssh}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
