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
    "async"
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
in
{
  fileSystems."/boot" = {
    fsType = "vfat";
    options = bootMountOptions;
  };

  fileSystems."/" = {
    fsType = "xfs";
    options = rootMountOptions;
  };

  fileSystems."/home" = {
    fsType = "xfs";
    options = homeMountOptions;
  };

  fileSystems."/var" = {
    fsType = "xfs";
    options = varlMountOptions;
  };
}
