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
    ./builder.nix
    ./server.nix
  ];
}
