{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./arm-soc-assertion.nix
    ./riscv-soc-assertion.nix
  ];
}
