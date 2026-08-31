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
      boot = "1BC0-F0DA";
      root = "96a4d247-e5fe-44ad-9e44-66b24037beb8";
    };
  };
}
