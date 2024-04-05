{ config
, lib
, pkgs
, systemUser
, ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  home.homeDirectory = "/home/${systemUser.username}";
  targets.genericLinux.enable = true;
}
