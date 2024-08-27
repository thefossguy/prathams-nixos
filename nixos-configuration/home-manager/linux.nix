{ lib, pkgs, systemUser, ... }@args:

lib.mkIf pkgs.stdenv.isLinux {
  home.homeDirectory = "/home/${args.nixosSystem.systemUser.username or systemUser.username}";
  targets.genericLinux.enable = true;
}
