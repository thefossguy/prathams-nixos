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
    ./base-config.nix
    ./bspwm.nix
    ./cosmic.nix
    ./hyprland.nix
    ./kde.nix
    ./z-wayland.nix
  ];
}
