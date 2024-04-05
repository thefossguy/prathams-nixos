{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d5d557ca-8fc5-42d0-9147-8bd9abb0da93";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2785-9017";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/279c46fc-8992-4c4f-9b2f-2d5d449376e3";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/a94c6019-138c-4b34-ad9c-97465cd9c136";
    fsType = "xfs";
  };
}
