{ config, lib, pkgs, ... }:

let
  connectivityCheckScript = import ../includes/misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    exitCode = "0";
    inherit pkgs;
  };

  serviceScript = if (config.systemd.services."continuous-build".enable or false)
    then ""
    else ''
      ${connectivityCheckScript}

      [[ ! -d /etc/nixos/.git ]] && git clone https://gitlab.com/thefossguy/prathams-nixos /etc/nixos
      pushd /etc/nixos
      git pull
      nix flake update
      popd
  '';
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
        systemd
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        ${serviceScript}

        nixos-rebuild boot --show-trace --print-build-logs --flake /etc/nixos#${config.networking.hostName}
      '';
    };
  };
}
