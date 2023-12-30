{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.timers = {
      "update-rust" = {
        Unit = {
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
          Description = "Upgrade the Rust toolchain";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash $HOME/.local/scripts/other-common-scripts/rust-manage.sh";
          Environment = [ "\"PATH=${pkgs.procps}/bin:${pkgs.rustup}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
