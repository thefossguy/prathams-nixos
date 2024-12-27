{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.zpoolMaintainenceMonthly;
in
lib.mkIf (nixosSystemConfig.kernelConfig.kernelVersion == "longterm") {
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
      path = [ config.boot.kernelPackages.zfs.userspaceTools pkgs.gawk ];

      script = ''
        set -xuf -o pipefail

        # We do this for every ZFS pool imported in the system.
        for importedZpoolName in $(sudo zpool list -H -o name); do
            ZPOOL_DEVICES=( $(zpool list "''${importedZpoolName}" -v -H -P | grep '/dev/' | awk '{print $1}') )

            if zpool list "''${importedZpoolName}" -v -H -P -L | grep -q 'nvme'; then
                # zpool is made of SSDs
                # one by one, trim each SSD and perform a scrub to verify integrity
                for INDV_ZPOOL_DEV in "''${ZPOOL_DEVICES[@]}"; do
                    time zpool trim -w "''${importedZpoolName}" "''${INDV_ZPOOL_DEV}"
                    time zpool sync "''${importedZpoolName}"
                    time zpool scrub -w "''${importedZpoolName}"
                done
            else
                # zpool is made of HDDs
                # perform only a scrub
                time zpool sync "''${importedZpoolName}"
                time zpool scrub -w "''${importedZpoolName}"
            fi
        done

      '';
    };
  };
}
