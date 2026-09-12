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
      boot = "E288-BCDD";
      root = "542e0e9f-d6c5-4ade-934f-937e3101925e";
    };
  };
}
