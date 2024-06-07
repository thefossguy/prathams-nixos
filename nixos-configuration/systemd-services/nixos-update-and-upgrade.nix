{ config, lib, pkgs, flakeUri, systemUser, ... }:

{
  imports = [ ./lookahead-nixos-build.nix ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "daily"; # *-*-* 00:00:00
    flake = flakeUri;
    operation = "boot";
    persistent = false;
  };
}
