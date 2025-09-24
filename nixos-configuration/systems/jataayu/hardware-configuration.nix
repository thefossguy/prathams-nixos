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
    device = "/dev/disk/by-uuid/EE6F-50F8";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c9324356-31e5-4d18-80a4-2d578575c892";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e990d2b9-7d1c-4d6b-923a-d8e538fb184e";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/a3433bc6-0ac7-4233-832d-fbce7f184b0d";
  };
}
