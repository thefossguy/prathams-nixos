{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./custom-home-manager-upgrade.nix
    ./dotfiles-pull.nix
    ./flatpak-manage.nix
    ./get-redhat-csaf-vex.nix
    ./podman-container-services
    ./update-rust.nix
  ];
}
