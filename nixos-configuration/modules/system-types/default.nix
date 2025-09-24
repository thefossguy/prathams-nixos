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
    ./desktop.nix
    ./laptop.nix
    ./server.nix
  ];
}
