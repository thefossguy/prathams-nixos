{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  home.homeDirectory = "/home/${nixosSystemConfig.coreConfig.systemUser.username}";
  targets.genericLinux.enable = true;
}
