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
      boot = "A359-4C61";
      root = "970a032d-5e43-45a8-bd9d-6fb79b161662";
    };
  };
}
