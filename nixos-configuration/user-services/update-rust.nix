{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "update-rust" = {
        Unit = {
          Description = "Timer to routinely update items in my Rust toolchain";
        };
        Timer = {
          OnBootSec = "now";
          OnCalendar = "Mon *-*-* 04:00:00";
          Unit = "update-rust.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
    systemd.user.services = {
      "update-rust" = {
        Unit = {
          Description = "Service to routinely update items in my Rust toolchain";
        };
        Service = {
          ExecStart = "/home/pratham/.local/scripts/other-common-scripts/rust-manage.sh";
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
