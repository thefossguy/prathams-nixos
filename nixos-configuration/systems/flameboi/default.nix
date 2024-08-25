{ ... }:

{
  imports = [ ../../modules/display-server/kde-plasma.nix ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/05DF-FC6E";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3c7f4b5f-a96b-41c2-8934-457ac63b9122";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7e275e21-e939-4ef5-bbf7-011ed724655a";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/6e310ca4-9af3-48e6-80cd-5f9d32b60eca";
    fsType = "xfs";
  };
}
