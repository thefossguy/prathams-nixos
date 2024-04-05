{ config
, lib
, pkgs
, systemUser
, ...
}:

lib.mkIf pkgs.stdenv.isDarwin {
  home.homeDirectory = "/Users/${systemUser.username}";
}
