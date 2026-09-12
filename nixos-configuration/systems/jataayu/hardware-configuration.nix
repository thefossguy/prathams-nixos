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
      boot = "CFA7-3AB7";
      root = "84639c9b-8ac4-49f2-aac0-136ae1ca5cf2";
    };
  };
}
