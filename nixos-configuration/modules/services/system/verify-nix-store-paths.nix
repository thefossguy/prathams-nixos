{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.verifyNixStorePaths;
in
lib.mkIf
  ((!config.customOptions.localCaching.servesNixDerivations) || (!config.customOptions.localCaching.buildsNixDerivations))
  {

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

        path = [ pkgs.nix ];

        serviceConfig = {
          User = "root";
          Type = "oneshot";
        };

        script = "nix store verify --all --recursive --sigs-needed 1 >/dev/null 2>&1";
      };
    };
  }
