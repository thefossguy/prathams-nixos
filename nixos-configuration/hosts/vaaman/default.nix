{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/accc5327-e27a-4488-892f-205e90a2014a";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A241-A804";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1eab2121-ba7e-4f65-9a80-b20e7b01e0c2";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/4cf02ba0-5a03-4d06-8e80-67e87aadcffe";
    fsType = "xfs";
  };
}
