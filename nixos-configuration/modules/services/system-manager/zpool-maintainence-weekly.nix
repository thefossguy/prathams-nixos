{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.zpoolMaintainenceWeekly;
in
lib.mkIf (config.customOptions.kernelConfiguration.tree == "longterm") {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      serviceConfig.User = "root";
      serviceConfig.Type = "oneshot";
      path = [ config.boot.kernelPackages.${pkgs.zfs.kernelModuleAttribute}.userspaceTools ];

      script = ''
        set -xuf -o pipefail

        for importedZpoolName in $(zpool list -H -o name); do
            zpool scrub -w "''${importedZpoolName}"
        done
      '';
    };
  };
}
