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
    ../packages/system-packages.nix
    ./autologin
    ./base-config
    ./cpu-microcode
    ./display-server
    ./gpu
    ./kernel-development
    ./local-nix-cache
    ./qemu
    ./soc-support
    ./system-types
    ./wg-vpn
  ];
}
