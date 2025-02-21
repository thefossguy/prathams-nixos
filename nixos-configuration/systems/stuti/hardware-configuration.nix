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
    device = "/dev/disk/by-uuid/B4DF-D804";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e3c37f3e-d920-4ec3-b80a-0ce53fabe98b";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/df2f3866-9c7e-4f22-85ba-7f3ef3fe3e5c";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/8507cc8d-8f9c-4360-b617-c628cd333bde";
  };
}
