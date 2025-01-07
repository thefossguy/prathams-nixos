{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/624E-EE88";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9ce0d088-217f-431c-bf09-7f139e9bbc24";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d1a9161e-d8c2-4bf5-981d-20efbe5804fe";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/b5818f6d-d369-4bab-82ba-402afd7a4460";
  };
}
