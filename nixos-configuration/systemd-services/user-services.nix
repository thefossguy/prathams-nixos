{ lib, pkgs, systemUser, ... }:

let scriptsDir = "/home/${systemUser.username}/.local/scripts";

in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.services = {
    "dotfiles-pull" = {
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/dotfiles-pull.sh";
        Environment = [ ''"PATH=${pkgs.git}/bin:${pkgs.openssh}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    "flatpak-manage" = {
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/flatpak-manage.sh";
        Environment = [ ''"PATH=${pkgs.gnugrep}/bin:${pkgs.flatpak}/bin:${pkgs.coreutils}/bin:${pkgs.desktop-file-utils}/bin:${pkgs.findutils}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    "update-rust" = {
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/rust-manage.sh ${pkgs.rustup}/bin/rustup";
        Environment = [ ''"PATH=${pkgs.procps}/bin"'' ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  systemd.user.timers = {
    "dotfiles-pull" = {
      Timer = {
        OnBootSec = "10m";
        OnCalendar = "*-*-* 18:00:00";
        Unit = "dotfiles-pull.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

    "flatpak-manage" = {
      Timer = {
        OnBootSec = "10m";
        OnCalendar = "*-*-* 18:00:00";
        Unit = "flatpak-manage.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };

    "update-rust" = {
      Timer = {
        OnBootSec = "10m";
        OnCalendar = "*-*-* 18:00:00";
        Unit = "update-rust.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
