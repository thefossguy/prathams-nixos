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
    ./common-rpi-config.nix
    ./rpi4.nix
    ./rpi5.nix
  ];
}
