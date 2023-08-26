{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "dotfiles-pull" = {
        Unit = {
          Description = "Timer to routinely pull thefossguy/dotfiles.git";
          Documentation = [
            "man:git-pull(1)"
          ];
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
          Description = "Service to routinely pull thefossguy/dotfiles.git";
          Documentation = [
            "man:git-pull(1)"
          ];
        };
        Service = {
          ExecStart = "/home/pratham/.local/scripts/other-common-scripts/dotfiles-pull.sh";
          Environment = [ "\"PATH=${pkgs.nix}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
