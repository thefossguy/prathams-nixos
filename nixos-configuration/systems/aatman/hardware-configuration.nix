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
    device = "/dev/disk/by-uuid/3BE1-D40E";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4a6db34a-af0d-465e-bab5-dea1849c9ebd";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3000a6ec-0ae9-43bf-8dab-65c44b54d050";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/99b70880-5aa7-43ba-989f-0d958125e45d";
  };
}
