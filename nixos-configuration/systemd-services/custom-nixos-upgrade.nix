{ config, lib, pkgs, ... }:

let
  connectivityCheckScript = import ../includes/misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    exitCode = 0;
    inherit pkgs;
  };
in

{
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

  systemd = {
    timers."custom-nixos-upgrade" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "custom-nixos-upgrade";

        OnBootSec = "10m";
        OnCalendar = "hourly";
      };
    };

    services."custom-nixos-upgrade" = {
      enable = true;
      path = with pkgs; [
        gitMinimal
        nix
        nixos-rebuild
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        ${connectivityCheckScript}

        [[ ! -d /etc/nixos/.git ]] && git clone https://gitlab.com/thefossguy/prathams-nixos /etc/nixos
        pushd /etc/nixos
        git pull
        nix flake update
        popd

        nixos-rebuild boot --show-trace --verbose --flake /etc/nixos#${config.networking.hostName}
      '';
    };
  };
}
