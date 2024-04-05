{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ../../includes/display-server/bspwm.nix ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a1cd227c-930a-4e7c-a8c8-9079fe21830b";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BE69-FC51";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/a1c34270-6725-4e0c-8b13-51ce53b07eb4";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/676c78ca-249b-46d8-8c98-f6853cf3479c";
    fsType = "xfs";
  };
}
