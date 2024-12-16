{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ../../packages/user-packages.nix
    ../services/user
  ];

  home.stateVersion = lib.versions.majorMinor lib.version;
  home.username = nixosSystemConfig.coreConfig.systemUser.username;
}
