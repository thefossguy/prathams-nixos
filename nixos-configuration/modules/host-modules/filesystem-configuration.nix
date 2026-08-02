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
      btrfsSubvolumeOption = "subvolume=@${fsMountPointWithoutLeadingForwardSlash}";
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
