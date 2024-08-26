{ lib, systemUser, ... }:

{
  imports = [
    ../packages/user-packages.nix
    ../modules/services/user-services.nix
    ./darwin.nix
    ./linux.nix
  ];

  home.stateVersion = lib.versions.majorMinor lib.version;
  home.username = "${systemUser.username}";
}
