{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ../services
    ./filesystem-configuration.nix
    ./podman.nix
    ./static-ip-and-virt-bridge.nix
    ./user-configuration.nix
  ];

  networking.hostId = nixosSystemConfig.coreConfig.hostId;
  networking.hostName = nixosSystemConfig.coreConfig.hostname;
}
