{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    useAlternativeSSHPort = true;
    useMinimalConfig = lib.mkForce true;
    virtualisation.enable = false; # explicitly disable virtualisation
    x86CpuVendor = "amd";
  };
}
