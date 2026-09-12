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
      boot = "E920-66D3X";
      root = "0e0a780c-a145-40e1-bf8c-d1d8dce72571";
    };
  };
}
