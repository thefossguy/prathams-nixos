{ config
, lib
, pkgs
, nixpkgsRelease
, systemUser
, ...
}:

{
  imports = [
    ../packages/user-packages.nix
    ../systemd-services/user-services.nix
    ./darwin.nix
    ./linux.nix
  ];

  home.stateVersion = "${nixpkgsRelease}";
  home.username = "${systemUser.username}";
}
