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
    device = "/dev/disk/by-uuid/872D-2C37";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/600c3c8e-0a5a-4a20-b21c-7a1d6e4600f2";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/33d378f4-b7eb-420a-ac74-0a1b2f8e4a29";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/48ffa645-be5d-494e-bb36-03ebbb0d219a";
  };
}
