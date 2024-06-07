{ config, lib, pkgs, systemUser, ... }:

let
  homeDir = "/home/${systemUser.username}";
  scriptsDir = "${homeDir}/.local/scripts";

in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.services = {
    "upgrade-my-home" = {
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/upgrade-my-home.sh";
        Environment = [
          ''"PATH=${pkgs.git}/bin:${pkgs.home-manager}/bin:${pkgs.nix}/bin:${pkgs.openssh}/bin:$PATH"''
          ''"HOME=${homeDir}"''
        ];
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  systemd.user.timers = {
    "upgrade-my-home" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "Monday *-*-* 07:00:00";
        Unit = "upgrade-my-home.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
