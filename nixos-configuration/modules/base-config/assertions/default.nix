{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./arm-soc-assertion.nix
    ./cosmic-iso.nix
    ./riscv-soc-assertion.nix
  ];
}
