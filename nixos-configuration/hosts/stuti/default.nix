{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/034f008d-8115-434d-a1c3-5f5856541f47";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/58A7-89EC";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7ab7b823-0aa6-48e2-b16a-b9491ce75c31";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e54efc9e-2e7b-4ae0-9b44-12057eb95f22";
    fsType = "xfs";
  };
}
