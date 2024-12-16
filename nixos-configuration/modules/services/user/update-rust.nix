{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.updateRust;
  scriptsDir = "${config.home.homeDirectory}/.local/scripts";
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      bash
      git
      openssh
      openssl
    ];
  };
in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = { RequiredBy = [ "timers.target" ]; };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
        OnBootSec = "10m";
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = { WantedBy = [ "default.target" ]; };
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];

        ExecStart = "bash ${scriptsDir}/other-common-scripts/rust-manage.sh ${pkgs.rustup}/bin/rustup";
      };
    };
  };
}
