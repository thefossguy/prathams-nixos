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
    ./binary-cache.nix
    ./builder.nix
    ./server.nix
  ];
}
