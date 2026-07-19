{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ../services
    ./filesystem-configuration.nix
    ./gb10.nix
    ./luks.nix
    ./podman.nix
    ./router.nix
    ./static-ip-and-virt-bridge.nix
    ./user-configuration.nix
  ];

  networking.hostId = nixosSystemConfig.coreConfig.hostId;
  networking.hostName = nixosSystemConfig.coreConfig.hostname;
}
