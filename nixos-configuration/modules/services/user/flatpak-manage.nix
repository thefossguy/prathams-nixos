{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  enableService =
    if nixosSystemConfig.coreConfig.isNixOS then
      ((osConfig.customOptions.displayServer.guiSession or "unset") != "unset")
    else
      pkgs.stdenv.isLinux;

  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.flatpakManage;
  scriptsDir = "${config.home.homeDirectory}/.local/scripts";
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      bash
      coreutils
      desktop-file-utils
      findutils
      flatpak
      gnugrep
      gnused
    ];
  };
in
lib.attrsets.optionalAttrs enableService {
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
        ExecStart = "${scriptsDir}/other-common-scripts/flatpak-manage.sh";
      };
    };
  };
}
