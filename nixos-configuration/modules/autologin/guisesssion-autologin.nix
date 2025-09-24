{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.autologinSettings.guiSession.enableAutologin || config.customOptions.isIso) {
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = nixosSystemConfig.coreConfig.systemUser.username;
}
