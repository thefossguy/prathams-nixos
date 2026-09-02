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
  commonMountOptions = [
    "relatime"
    "lazytime"
  ];
  hardenedMountOptions = [
    "nodev"
    "nosuid"
  ];
  bootMountOptions =
    commonMountOptions
    ++ hardenedMountOptions
    ++ [
      "noexec"
      "umask=0077"
    ];
  rootMountOptions = commonMountOptions ++ hardenedMountOptions;
  addAsyncOption = mountPath: lib.optionals (config.fileSystems."${mountPath}".fsType != "zfs") [ "async" ];

  getFsType = mountPoint: if (mountPoint == "/boot") then "vfat" else config.customOptions.fileSystems.rootFileSystem;
  makeSubFileSystemName =
    { mountPoint, rootfsIsZfs }:
    let
      filesystemLabel = if rootfsIsZfs then "${config.customOptions.fileSystems.zpoolName}/rootfs" else "rootfs";
    in
    if (mountPoint == "/") then
      filesystemLabel
    else
      "${filesystemLabel}${builtins.replaceStrings [ "/" ] [ "-" ] mountPoint}";
  getDevice =
    mountPoint:
    if (mountPoint == "/boot") then
      config.customOptions.fileSystems.devices.boot
    else if (config.customOptions.fileSystems.rootFileSystem == "zfs") then
      makeSubFileSystemName {
        inherit mountPoint;
        rootfsIsZfs = true;
      }
    else
      config.customOptions.fileSystems.devices.root;
  getMountOptions =
    { mountPoint, fsType }:
    let
      btrfsSubvolumeOption = "subvol=@${
        makeSubFileSystemName {
          inherit mountPoint;
          rootfsIsZfs = false;
        }
      }";
    in
    {
      vfat = bootMountOptions;
      btrfs = [
        "async"
        "compress=zstd:15"
        btrfsSubvolumeOption
      ];
      xfs = [ "async" ];
      zfs = [ ];
    }
    .${fsType}
    ++ rootMountOptions;

  rootfsFileSystem = config.fileSystems."/".fsType;
in

{
  boot.initrd.systemd.services = lib.mkIf (rootfsFileSystem == "btrfs") {
    rollback-root =
      let
        rollbackScriptsSet = {
          btrfs = {
            script =
              let
                filteredMountOptions = builtins.filter (rootfsOption: rootfsOption != "subvol=@") config.fileSystems."/".options;
                finalMountPointOptions = builtins.concatStringsSep "," ([ "subvolid=5" ] ++ filteredMountOptions);
              in
              ''
                set -x

                mkdir --verbose --parents /btrfs/old
                mount --options ${finalMountPointOptions} ${config.customOptions.fileSystems.devices.root} /btrfs/old

                if [ -d '/btrfs/old/@+fresh' ]; then
                    btrfs subvolume delete '/btrfs/old/@'
                    btrfs subvolume snapshot '/btrfs/old/@+fresh' '/btrfs/old/@'
                else
                    echo 'rollback-root: @+fresh snapshot not found, aborting rollback' >&2
                fi

                umount --verbose --recursive /btrfs/old
              '';
          };
        };
      in
      {
        description = "Rollback rootfs to a blank snapshot";
        wantedBy = [ "initrd.target" ];
        requiredBy = [ "sysroot.mount" ];
        requires = [
          "${utils.escapeSystemdPath config.customOptions.fileSystems.devices.root}.device"
          "modprobe@${rootfsFileSystem}.service"
        ];
        before = config.boot.initrd.systemd.services.rollback-root.requiredBy;
        after = config.boot.initrd.systemd.services.rollback-root.requires;
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;

        inherit (rollbackScriptsSet.${rootfsFileSystem}) script;
      };
  };

  fileSystems =
    if (config.customOptions.fileSystems.rootFileSystem != "xfs") then
      (builtins.foldl' (
        acc: mountPoint:
        acc
        // {
          ${mountPoint} =
            let
              fsType = getFsType mountPoint;
            in
            {
              inherit fsType;
              device = getDevice mountPoint;
              options = getMountOptions { inherit mountPoint fsType; };
            };
        }
      ) { } config.customOptions.fileSystems.fileSystemsOnRootfsDevice)
    else
      {
        "/boot" = {
          fsType = "vfat";
          options = bootMountOptions ++ addAsyncOption "/boot";
        };

        "/" = {
          fsType = config.customOptions.fileSystems.rootFileSystem;
          options = rootMountOptions ++ addAsyncOption "/";
        };

        "/home" = {
          fsType = config.customOptions.fileSystems.rootFileSystem;
          options = rootMountOptions ++ addAsyncOption "/home";
        };

        "/var" = {
          fsType = config.customOptions.fileSystems.rootFileSystem;
          options = rootMountOptions ++ addAsyncOption "/var";
        };
      };
}
