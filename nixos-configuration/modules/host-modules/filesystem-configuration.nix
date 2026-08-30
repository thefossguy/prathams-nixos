{
  config,
  lib,
  pkgs,
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
  getDevice =
    mountPoint:
    if (mountPoint == "/boot") then
      config.customOptions.fileSystems.devices.boot
    else
      config.customOptions.fileSystems.devices.root;
  getMountOptions =
    { mountPoint, fsType }:
    let
      mountPointLength = builtins.stringLength mountPoint;
      fsMountPointWithoutLeadingForwardSlash = builtins.substring 1 (mountPointLength - 1) mountPoint;
      btrfsSubvolumeName = builtins.replaceStrings [ "/" ] [ "-" ] fsMountPointWithoutLeadingForwardSlash;
      btrfsSubvolumeOption = "subvol=@${btrfsSubvolumeName}";
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
in
{

  boot.initrd.systemd.services.rollback-root = {
    description = "Rollback rootfs to a blank snapshot";
    wantedBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];
    after = [ "systemd-udev-settle.service" ];
    unitConfig.defaultDependencies = false;
    serviceConfig.type = "oneshot";

    script =
      let
        commonPkgs = with pkgs; [
          coreutils-full
          util-linux
        ];
        rollbackScript = {
          xfs = ''
            # intentionally left empty; snapshotting (and therefore rollbacks) are unsupported on XFS
          '';

          zfs =
            let
              fsProgs = commonPkgs ++ [ config.boot.kernelPackages.${pkgs.zfs.kernelModuleAttribute}.userspaceTools ];
            in
            ''
              export PATH=${lib.makeBinPath (builtins.map (pkg: pkg.out or pkg) fsProgs)}:$PATH
            '';

          btrfs =
            let
              fsProgs = commonPkgs ++ [ pkgs.btrfs-progs ];
            in
            ''
              export PATH=${lib.makeBinPath (builtins.map (pkg: pkg.out or pkg) fsProgs)}:$PATH

              mkdir --verbose --parents /btrfs/old
              mount --options ${
                builtins.concatStringsSep "," config.fileSystems."/".options
              } ${config.fileSystems."/".device} /btrfs/old

              if [ -d '/btrfs/old/@+fresh' ]; then
                  btrfs subvolume delete '/btrfs/old@'
                  btrfs subvolume snapshot '/btrfs/old@+fresh' '/btrfs/old@'
              else
                  echo 'rollback-root: @+fresh snapshot not found, aborting rollback' >&2
              fi

              umount --verbose --recursive /btrfs/old
            '';
        };
      in
      rollbackScript.${config.fileSystems."/".fsType} or null;
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
