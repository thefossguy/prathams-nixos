{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.customNixosUpgrade;
in {
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = serviceConfig.unitName;
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;
      path = with pkgs; [ gitMinimal nix nixos-rebuild systemd ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "nixos-rebuild boot --show-trace --print-build-logs --flake /etc/nixos#${config.networking.hostName}";
    };
  };
}
