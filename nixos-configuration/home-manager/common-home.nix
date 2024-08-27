{ lib, systemUser, ... }@args:

{
  imports = [
    ../packages/user-packages.nix
    ../modules/services/user-services.nix
    ./darwin.nix
    ./linux.nix
  ];

  home.stateVersion = lib.versions.majorMinor lib.version;
  home.username = "${args.nixosSystem.systemUser.username or systemUser.username}";
}
