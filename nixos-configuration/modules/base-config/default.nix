{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./assertions
    ./bootloader-configuration.nix
    ./configuration.nix
    ./custom-options.nix
    ./ether-dev-names-with-mac-addr.nix
    ./kernel-packages.nix
    ./misc-configuration.nix
    ./network-configuration.nix
    ./nix-config.nix
    ./sudo-nopasswd.nix
    ./sysctls.nix
    ./virtualisation.nix
    ./zfs.nix
    ./zram-swap.nix
  ];
}
