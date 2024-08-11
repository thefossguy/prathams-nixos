{ config, lib, pkgs, ... }:

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
      after    = [ "update-nixos-flake-inputs.service" ];
      requires = [ "update-nixos-flake-inputs.service" ];
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

      script = "nixos-rebuild boot --show-trace --print-build-logs --flake /etc/nixos#${config.networking.hostName}";
    };
  };
}
