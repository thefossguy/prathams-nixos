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
    ./custom-home-manager-upgrade.nix
    ./dotfiles-pull.nix
    ./flatpak-manage.nix
    ./manually-autostart-libvirt-vms.nix
    ./nvim-update-plugins-and-parsers.nix
    ./update-rust.nix
  ];
}
