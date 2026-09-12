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
      boot = "C49E-FA0F";
      root = "1aa34cc7-0530-49e6-b948-e94db26bebcf";
    };
  };
}
