{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    virtualisation.enable = true;
    x86CpuVendor = "amd";
    useMinimalConfig = lib.mkForce false;
    localCaching.buildsNixDerivations = true;
  };
}
