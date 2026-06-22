{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.customNixosUpgrade;
in
{
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;
      environment = {
        NIXOS_MACHINE_HOSTNAME = config.networking.hostName;
      };
      path = with pkgs; [
        gitMinimal
        nix
        nixos-rebuild
        python3Minimal
        systemd
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = "/etc/nixos/scripts/nixos/custom-nixos-upgrade.py";
      };
    };
  };
}
