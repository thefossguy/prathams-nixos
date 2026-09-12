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
      boot = "AF87-CC05";
      root = "31fb239f-1410-475f-a96d-8b50db8508e4";
    };
  };
}
