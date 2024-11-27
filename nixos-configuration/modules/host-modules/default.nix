{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ../autologin
    ../services
    ./podman.nix
    ./static-ip-and-virt-bridge.nix
    ./user-configuration.nix
  ];

  networking.hostId = nixosSystemConfig.coreConfig.hostId;
  networking.hostName = nixosSystemConfig.coreConfig.hostname;
}
