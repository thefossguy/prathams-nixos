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
      boot = "AAFB-BF6E";
      root = "96a4d247-e5fe-44ad-9e44-66b24037beb8";
    };
  };
}
