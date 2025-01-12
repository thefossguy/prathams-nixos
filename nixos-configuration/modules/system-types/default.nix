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
    ./desktop.nix
    ./laptop.nix
    ./server.nix
  ];
}
