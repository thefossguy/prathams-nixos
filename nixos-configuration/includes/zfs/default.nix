{ config, lib, pkgs, forceLtsKernel ? false, latestLtsKernel, supportedFilesystemsSansZFS, ... }:

let
  latestLtsKernelPackage = pkgs."${latestLtsKernel}";
  allSupportedFilesystems = supportedFilesystemsSansZFS ++ [ "zfs" ];
  zpoolName = "${config.networking.hostName}-zpool";
in

lib.mkIf forceLtsKernel {
  boot = {
    # we force them because we want to override values from `nixos-configuration/hosts/hosts-common.nix`
    kernelPackages = lib.mkForce latestLtsKernelPackage;
    initrd.supportedFilesystems = lib.mkForce allSupportedFilesystems;
    supportedFilesystems = lib.mkForce allSupportedFilesystems;

    zfs.allowHibernation = lib.mkForce false;
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
  };

  security.pam.zfs.enable = true;
  security.pam.zfs.noUnmount = false;

  # we do this manually, because I have OCD and always divert from "one size fits all"
  services.zfs.autoScrub.enable = lib.mkForce false;
  services.zfs.autoSnapshot.enable = lib.mkForce false;
  services.zfs.trim.enable = lib.mkForce false;

  systemd = {
    timers = {
      "custom-zpool-maintainence" = {
        enable = true;
        requiredBy = [ "timers.target" ];

        timerConfig = {
          Unit = "custom-zpool-maintainence";
          OnCalendar = "Fri *-*-* 00:00:00";
        };
      };

      "full-zpool-maintainence" = {
        enable = true;
        requiredBy = [ "timers.target" ];

        timerConfig = {
          Unit = "full-zpool-maintainence";
          OnCalendar = "monthly";
        };
      };
    };

    services = {
      "custom-zpool-maintainence" = {
        enable = true;
        serviceConfig = {
          User = "root";
          Type = "oneshot";
        };
        script = ''${latestLtsKernelPackage.zfs.userspaceTools} scrub -w ${config.networking.hostName}-zpool'';
      };

      "full-zpool-maintainence" = {
        enable = true;
        path = [ latestLtsKernelPackage.zfs.userspaceTools pkgs.gawk ];
        serviceConfig = {
          User = "root";
          Type = "oneshot";
        };

        script = ''
          set -xuf -o pipefail

          # first, we find the devices in a zpool
          ZPOOL_DEVICES=( $(zpool list ${zpoolName} -v -H -P | grep '/dev/' | awk '{print $1}') )

          for INDV_ZPOOL_DEV in "''${ZPOOL_DEVICES[@]}"; do
              time zpool trim -w ${zpoolName} "''${INDV_ZPOOL_DEV}"
              time zpool sync ${zpoolName}
              time zpool scrub -w ${zpoolName}
          done
        '';
      };
    };
  };
}
