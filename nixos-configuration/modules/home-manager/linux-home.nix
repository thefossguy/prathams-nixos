{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  home.homeDirectory = "/home/${nixosSystemConfig.coreConfig.systemUser.username}";
  targets.genericLinux.enable = true;
}
