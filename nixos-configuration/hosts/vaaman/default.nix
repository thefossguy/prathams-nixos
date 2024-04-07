{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D546-9873";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4844363d-0dff-4dd2-88d8-704de750fe09";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/6be45b33-103b-4679-b657-a8faeec3f8f6";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/12fb6827-ac35-4400-ad9c-1763cd94e37f";
    fsType = "xfs";
  };
}
