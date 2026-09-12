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
      boot = "FA10-C324";
      root = "2c7697a0-4bcf-44f4-9c49-4b3d1c2b3496";
    };
  };
}
