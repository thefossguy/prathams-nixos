{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.dotfilesPull;
  scriptsDir = "${config.home.homeDirectory}/.local/scripts";
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      bash
      coreutils
      git
      iputils
      openssh
      openssl
    ];
  };
in
lib.mkIf pkgs.stdenv.isLinux {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = {
        RequiredBy = [ "timers.target" ];
      };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
        OnBootSec = "10m";
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];
        ExecStart = "${scriptsDir}/other-common-scripts/dotfiles-pull.sh";
      };
    };
  };
}
