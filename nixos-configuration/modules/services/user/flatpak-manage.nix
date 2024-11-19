{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
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
in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = { RequiredBy = [ "timers.target" ]; };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = { WantedBy = [ "default.target" ]; };
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];
        ExecStart = "bash ${scriptsDir}/other-common-scripts/flatpak-manage.sh";
      };
    };
  };
}
