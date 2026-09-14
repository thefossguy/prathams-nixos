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
      boot = "B633-B21E";
      root = "456e3903-581f-46f4-b69d-62a42f785c4e";
    };
  };
}
