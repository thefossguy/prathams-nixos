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
    ./bootloader-configuration.nix
    ./configuration.nix
    ./custom-options.nix
    ./dev-names-with-mac-addr.nix
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
