{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.autologinSettings.getty.enableAutologin || config.customOptions.isIso) {
  services.getty.autologinUser = nixosSystemConfig.coreConfig.systemUser.username;
}
