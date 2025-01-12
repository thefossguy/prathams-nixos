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
    device = "/dev/disk/by-uuid/15D7-1EF4";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c78f0691-a246-4b01-bb33-41662abcb2d6";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9f8f26e5-5fc3-4f4a-ae45-4f24151e846e";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/cb9dcd35-891b-438f-baa1-fd3278dc3069";
  };
}
