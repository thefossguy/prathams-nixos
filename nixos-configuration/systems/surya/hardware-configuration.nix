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
    device = "/dev/disk/by-uuid/E4E6-A483";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e7b48d5e-fbf9-4862-9a62-73e8aa63cea9";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/4bf9b769-1ce7-4f91-ae9a-ea162ad5a6d9";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/a5006def-8a1e-4186-a9de-f14929d4f973";
  };
}
