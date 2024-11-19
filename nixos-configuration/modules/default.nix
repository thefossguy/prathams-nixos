{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ../packages/system-packages.nix
    ./base-config
    ./cpu-microcode
    ./display-server
    ./gpu
    ./local-nix-cache
    ./qemu
    ./soc-support
    ./system-types
  ];
}
