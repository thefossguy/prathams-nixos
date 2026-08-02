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
    ./builder.nix
    ./harmonia.nix
    ./server.nix
  ];
}
