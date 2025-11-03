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
  bootMountOptions = commonMountOptions ++ hardenedMountOptions ++ [ "noexec" ];
  rootMountOptions = commonMountOptions ++ hardenedMountOptions;
  homeMountOptions = commonMountOptions ++ hardenedMountOptions;
  varlMountOptions = commonMountOptions ++ hardenedMountOptions;

  addAsyncOption = mountPath: lib.optionals (config.fileSystems."${mountPath}".fsType != "zfs") [ "async" ];
in
{
  fileSystems."/boot" = {
    fsType = "vfat";
    options = bootMountOptions ++ addAsyncOption "/boot";
  };

  fileSystems."/" = {
    fsType = "xfs";
    options = rootMountOptions ++ addAsyncOption "/";
  };

  fileSystems."/home" = {
    fsType = "xfs";
    options = homeMountOptions ++ addAsyncOption "/home";
  };

  fileSystems."/var" = {
    fsType = "xfs";
    options = varlMountOptions ++ addAsyncOption "/var";
  };
}
