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
      boot = "F289-B3A2";
      root = "7968695f-4449-4a8c-8797-557a9dd53244";
    };
  };
}
