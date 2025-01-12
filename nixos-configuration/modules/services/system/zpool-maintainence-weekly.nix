{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.zpoolMaintainenceWeekly;
in
lib.attrsets.optionalAttrs (nixosSystemConfig.kernelConfig.kernelVersion == "longterm") {
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
      path = [ config.boot.kernelPackages.zfs.userspaceTools ];

      script = ''
        set -xuf -o pipefail

        for importedZpoolName in $(sudo zpool list -H -o name); do
            zpool scrub -w "''${importedZpoolName}"
        done
      '';
    };
  };
}
