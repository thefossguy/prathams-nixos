{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

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
