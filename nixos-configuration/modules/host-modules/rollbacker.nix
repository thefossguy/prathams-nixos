{
  config,
  lib,
  pkgs,
  utils,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  cfg = config.services.rollbacker;
in

{
  meta.maintainers = with lib.maintainers; [ thefossguy ];

  options = {
    services.rollbacker = {
      enable = lib.mkEnableOption "Enable the rollbacker service";

      mountPoint = lib.mkOption {
        description = "";
        type = lib.types.str;
        default = "/mnt/rollbacker";
      };

      freshSnapshotSuffix = lib.mkOption {
        description = "The suffix of a snapshot such that `subvol+suffix` or `dataset+suffix` is the fresh snapshot of that subvol/dataset.";
        type = lib.types.str;
        default = "@:fresh";
      };

      package = lib.mkPackageOption pkgs "rollbacker" { };
    };
  };

  config =
    let
      groupedFileSystems = builtins.groupBy (mountPoint: mountPoint.device) (builtins.attrValues config.fileSystems);
      systemdUnits = builtins.map (
        mountPointConfigSet:
        let
          mountPointConfigSetHead = builtins.head mountPointConfigSet;
          deviceMountPoints = builtins.map (localMountPointConfigSet: localMountPointConfigSet.mountPoint) mountPointConfigSet;
          systemdDeviceMountPoints = (
            builtins.map (deviceMountPoint: "${utils.escapeSystemdPath deviceMountPoint}.mount") deviceMountPoints
          );
          fsType = mountPointConfigSetHead.fsType;

          systemdUnitsSetInner = {
            "btrfs" =
              let
                device = mountPointConfigSetHead.device;
                splitDevice = builtins.split "/" device;
                splitDeviceLen = builtins.length splitDevice;
                splitDeviceLastIndex = splitDeviceLen - 1;
                splitDeviceLastElement = builtins.elemAt splitDevice splitDeviceLastIndex;
                localRollbackerMountPoint = "${cfg.mountPoint}/${splitDeviceLastElement}";
                serviceUnitBaseName = "rollbacker-btrfs-${splitDeviceLastElement}";
                escapedLocalRollbackerMountPoint = utils.escapeSystemdPath localRollbackerMountPoint;
                escapedDevice = utils.escapeSystemdPath device;
              in
              {
                mounts = [
                  {
                    after = [ "${escapedDevice}.device" ];
                    requires = [ "${escapedDevice}.device" ];
                    partOf = [ "${serviceUnitBaseName}.service" ];

                    what = device;
                    where = localRollbackerMountPoint;
                    type = "btrfs";
                    options = "subvolid=5";
                  }
                ];
                services = {
                  "${serviceUnitBaseName}" = {
                    after = [
                      "${escapedLocalRollbackerMountPoint}.mount"
                      "initrd-root-device.target"
                    ];
                    before = [
                      "sysroot.mount"
                      "local-pre-fs.target"
                    ]
                    ++ systemdDeviceMountPoints;
                    wantedBy = [ "initrd.target" ] ++ systemdDeviceMountPoints;
                    requiredBy = systemdDeviceMountPoints;

                    path = [
                      pkgs.rollbacker
                      pkgs.btrfs-progs
                    ];

                    unitConfig.DefaultDependencies = false;
                    serviceConfig.Type = "oneshot";
                    requires = [ "${escapedLocalRollbackerMountPoint}.mount" ];

                    serviceConfig.ExecStart = "${lib.getExe cfg.package} --filesystem-type btrfs --fresh-snapshot-suffix '${cfg.freshSnapshotSuffix}' --superblock-path ${localRollbackerMountPoint}";
                  };
                };
              };

            "zfs" =
              let
                zpool = (builtins.elemAt (builtins.split "/" mountPointConfigSetHead.device) 0);
              in
              {
                services = {
                  "rollbacker-zfs-${zpool}" = {
                    after = [
                      "initrd-root-device.target"
                      "zfs-import-${zpool}.service"
                    ];
                    before = [
                      "sysroot.mount"
                      "local-pre-fs.target"
                      "zfs-import.target"
                    ]
                    ++ systemdDeviceMountPoints;
                    wantedBy = [
                      "initrd.target"
                      "zfs-import.target"
                    ]
                    ++ systemdDeviceMountPoints;
                    requiredBy = systemdDeviceMountPoints;

                    path = [
                      pkgs.rollbacker
                      config.boot.kernelPackages.${pkgs.zfs.kernelModuleAttribute}.userspaceTools
                    ];

                    unitConfig.DefaultDependencies = false;
                    serviceConfig.Type = "oneshot";
                    requires = [ "zfs-import-${zpool}.service" ];

                    serviceConfig.ExecStart = "${lib.getExe cfg.package} --filesystem-type zfs --fresh-snapshot-suffix '${cfg.freshSnapshotSuffix}' --superblock-path ${zpool}";
                  };
                };

              };
          };
        in
        systemdUnitsSetInner.${fsType} or { }

      ) (builtins.attrValues groupedFileSystems);
    in
    lib.mkIf cfg.enable {
      boot.initrd.systemd = builtins.foldl' (acc: set: acc // set) { } systemdUnits;
    };
}
