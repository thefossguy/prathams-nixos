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
      boot = "AE28-F558";
      root = "8f69c47e-8ab9-49ac-bf69-770f185c92fa";
    };
  };
}
