{ config, lib, pkgs, systemUser, ... }:

{
  imports = [
    ../packages/user-packages.nix
    ../systemd-services/user-services.nix
    ./darwin.nix
    ./linux.nix
  ];

  home.stateVersion = lib.versions.majorMinor lib.version;
  home.username = "${systemUser.username}";
}
