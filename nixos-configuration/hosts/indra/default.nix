{ ... }:

{
  imports = [ ../../includes/display-server/kde-plasma.nix ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2C9D-5832";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ee12bd22-12e0-4840-8f16-46a9540bfbac";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/cffc2a40-66a3-4ae2-96f8-f6b9a55c12c7";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e19a752e-92e8-476a-b5e7-a9c16373fde5";
    fsType = "xfs";
  };
}
