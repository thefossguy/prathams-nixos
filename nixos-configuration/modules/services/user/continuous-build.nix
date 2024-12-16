{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.continuousBuild;
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      git
      nix
      openssh
      openssl
    ];
  };
in lib.mkIf (config.customOptions.localCaching.buildsNixDerivations or false) {
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

        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
          set -xeuf -o pipefail

          while [[ -f '/etc/nixos/flake-ci-started.log' ]]; do
              sleep 10
          done
          nix copy --no-check-sigs --to ssh-ng://chaturvyas /etc/nixos/result*
        ''}";
      };
    };
  };
}
