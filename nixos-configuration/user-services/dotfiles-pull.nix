{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "dotfiles-pull" = {
        Unit = {
        };
        Timer = {
          OnCalendar = "*-*-* 23:00:00";
          Unit = "dotfiles-pull.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
    systemd.user.services = {
      "dotfiles-pull" = {
        Unit = {
          Description = "Pull dotfiles";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash $HOME/.local/scripts/other-common-scripts/dotfiles-pull.sh";
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
