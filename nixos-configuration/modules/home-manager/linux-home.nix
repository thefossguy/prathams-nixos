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

  # home-manager is used as an environment manager, not another nixos
  # for the user, so disable this nonsense which also causes evaluation
  # errors on aarch64-linux
  targets.genericLinux.gpu = lib.mkForce false;
}
