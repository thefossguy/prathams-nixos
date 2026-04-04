{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.verifyNixStorePaths;
in
lib.mkIf (!config.customOptions.localCaching.servesNixDerivations) {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      before = serviceConfig.beforeUnits;
      requiredBy = serviceConfig.requiredByUnits;

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = "${pkgs.nix}/bin/nix-store --verify --check-contents --repair";
      };
    };
  };
}
