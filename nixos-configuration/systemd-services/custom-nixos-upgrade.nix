{ config, lib, pkgs, flakeUri, ... }:

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

      requires = [ "network-online.target" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        [[ ! -d ${flakeUri} ]] && git clone https://gitlab.com/thefossguy/prathams-nixos ${flakeUri}
        pushd ${flakeUri}
        git pull
        nix flake update
        popd

        nixos-rebuild boot --show-trace --verbose --flake ${flakeUri}#${config.networking.hostName}
      '';
    };
  };
}
