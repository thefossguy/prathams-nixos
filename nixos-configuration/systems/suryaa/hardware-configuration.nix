{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3C57-43EA";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3f9318b8-9194-40c8-938d-e590aab187e5";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/a607db5d-5199-4c83-adf9-04dd5d029778";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/bdfcee73-293b-4ae1-be0e-fea1b9722fcd";
  };
}
