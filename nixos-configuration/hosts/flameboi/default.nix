{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ../../includes/display-server/kde-plasma.nix ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/433ba433-7363-49bd-884f-105ef7d44d4d";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8CA9-4AE6";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/be968e24-086c-42d4-b7cb-ad7a4d2c4519";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e4f62604-a777-48e3-9426-42585906b313";
    fsType = "xfs";
  };
}
