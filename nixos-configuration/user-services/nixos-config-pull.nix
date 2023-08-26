{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "nixos-config-pull" = {
        Unit = {
          Description = "Timer to routinely pull thefossguy/prathams-nixos.git";
          Documentation = [
            "man:git-pull(1)"
          ];
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
          Description = "Service to routinely pull thefossguy/prathams-nixos.git";
          Documentation = [
            "man:git-pull(1)"
          ];
        };
        Service = {
          ExecStart = "/home/pratham/.local/scripts/other-common-scripts/nixos-config-pull.sh";
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
