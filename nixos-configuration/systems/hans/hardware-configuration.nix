{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CA4C-63B7";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8e8e0639-ff1e-4db2-ab48-626f3d3b3dc9";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/40e5bde0-480c-467e-a6bf-73d023888a77";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/5487cbf3-bf3e-4bdb-8ab9-6be4d025d45e";
  };
}
