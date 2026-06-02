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
    device = "/dev/disk/by-uuid/733C-DCA4";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/988d9091-9113-4aab-8edc-215dab26c850";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8a8af2e4-51ed-4d35-a801-da2b8c5082ee";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/834f6c4e-a9d9-4fa3-8069-12caa6f22857";
  };
}
