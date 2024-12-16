{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./kdev-host.nix
    ./kdev-vm.nix
  ];
}
