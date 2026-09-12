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
      boot = "FEEC-8CA0";
      root = "9715ca78-b9ca-4bc6-be0b-0d6df32a9809";
    };
  };
}
