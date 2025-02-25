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
    ../packages/system-packages.nix
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
