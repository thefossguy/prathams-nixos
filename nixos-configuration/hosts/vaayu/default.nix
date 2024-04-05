{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/38a4d542-af04-4226-8da2-d8af42f97595";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/13B7-7ADB";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d988233b-5e5d-4f2e-a30f-f34e529145da";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/9e09b3cd-e1e0-43f5-9573-bffb2d35822a";
    fsType = "xfs";
  };
}
