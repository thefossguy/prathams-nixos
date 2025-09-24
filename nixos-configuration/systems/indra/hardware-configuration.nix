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
    device = "/dev/disk/by-uuid/2C9D-5832";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ee12bd22-12e0-4840-8f16-46a9540bfbac";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/cffc2a40-66a3-4ae2-96f8-f6b9a55c12c7";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e19a752e-92e8-476a-b5e7-a9c16373fde5";
  };
}
