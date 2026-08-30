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
    fileSystemsOnRootfsDevice = [
      "/"
      "/boot"
      "/home"
      "/nix"
      "/persistent/data"
      "/persistent/state"
      "/var"
    ];
    UUIDs = {
      boot = "02D2-405F";
      root = "84639c9b-8ac4-49f2-aac0-136ae1ca5cf2";
    };
  };
}
