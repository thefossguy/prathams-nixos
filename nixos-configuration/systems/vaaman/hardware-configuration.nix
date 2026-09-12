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
      boot = "B937-B0DF";
      root = "2301186b-b974-4011-a5ee-283a1fb4120b";
    };
  };
}
