{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  customOptions.fileSystems = {
    rootFileSystem = "btrfs";
    UUIDs = {
      boot = "AE45-F80B";
      root = "67d7f855-29e3-4666-b9ac-cf0cf3f09cd2";
    };
  };
}
