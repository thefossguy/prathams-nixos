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
      zfs = [ "zfsutil" ];
    }
    .${fsType}
    ++ rootMountOptions
    ++ lib.optionals (mountPoint == "/nix/store") [ "ro" ];

  rootfsFileSystem = config.fileSystems."/".fsType;
in

{
  systemd.tmpfiles.settings = {
    "00-systemd-defaults-overrides" = {
      "/var/tmp".d = {
        mode = "1777";
        user = "root";
        group = "root";
      };
      "/var/lib/portables".d = {
        mode = "0777";
        user = "root";
        group = "root";
      };
      "/var/lib/machines".d = {
        mode = "0777";
        user = "root";
        group = "root";
      };
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
