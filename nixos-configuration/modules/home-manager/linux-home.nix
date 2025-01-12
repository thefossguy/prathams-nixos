{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
  home.homeDirectory = "/home/${nixosSystemConfig.coreConfig.systemUser.username}";
  targets.genericLinux.enable = true;
}
