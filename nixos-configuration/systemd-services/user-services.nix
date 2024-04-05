{ config
, lib
, pkgs
, ...
}:

let
  scriptsDir = "$HOME/.local/scripts";
in

lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.services = {
    "dotfiles-pull" = {
      Service = {
        ExecStart = "${pkgs.dash}/bin/dash ${scriptsDir}/other-common-scripts/dotfiles-pull.sh";
        Environment = [ ''"PATH=${pkgs.git}/bin:${pkgs.openssh}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    "flatpak-manage" = {
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/flatpak-manage.sh";
        Environment = [ ''"PATH=${pkgs.gnugrep}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    "update-rust" = {
      Service = {
        ExecStart = "${pkgs.dash}/bin/dash ${scriptsDir}/other-common-scripts/rust-manage.sh";
        Environment = [ ''"PATH=${pkgs.procps}/bin:${pkgs.rustup}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  systemd.user.timers = {
    "dotfiles-pull" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "*-*-* 23:00:00";
        Unit = "dotfiles-pull.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

    "flatpak-manage" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "*-*-* 04:00:00";
        Unit = "flatpak-manage.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

    "update-rust" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "*-*-* 04:00:00";
        Unit = "update-rust.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}