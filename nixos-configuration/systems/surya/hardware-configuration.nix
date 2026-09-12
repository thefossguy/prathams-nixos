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
      boot = "A183-A0B7";
      root = "271c4cff-a0ef-4af2-9490-b731c944ff7e";
    };
  };
}
