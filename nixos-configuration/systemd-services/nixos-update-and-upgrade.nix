{ config
, lib
, pkgs
, systemUser
, ...
}:

let
  flakeUri = "/root/prathams-nixos";
in

{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "daily"; # *-*-* 00:00:00
    flake = flakeUri;
    operation = "boot";
    persistent = false;
  };

  systemd = {
    timers."update-nixos-config" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "update-nixos-config";

        OnBootSec = "10m";
        OnCalendar = "hourly";
      };
    };

    services."update-nixos-config" = {
      enable = true;
      path = with pkgs; [
        nix
        gitMinimal
      ];

      requires = [ "network-online.target" ];
      before = [ "nixos-upgrade.service" ];
      requiredBy = [ "nixos-upgrade.service" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xeuf -o pipefail

        [[ ! -d ${flakeUri} ]] && git clone https://gitlab.com/thefossguy/prathams-nixos ${flakeUri}

        pushd ${flakeUri}
        [[ ! -f flake.nix ]] && git checkout flake-transition
        git restore flake.lock
        git pull
        nix flake update
        nix build --print-build-logs --show-trace --flake .#"$(hostname)"
        popd
      '';
    };
  };
}
