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
    device = "/dev/disk/by-uuid/B911-786F";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/83cf9d36-a97a-4336-ab3c-e818cc4edc30";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b8a89e3a-f6d9-456c-a554-6d6fd498ce46";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/7cb3c69f-2c62-4498-86e5-f168b3f2daa4";
  };
}
