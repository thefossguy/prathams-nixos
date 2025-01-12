{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.autologinSettings.getty.enableAutologin {
  services.getty.autologinUser = nixosSystemConfig.coreConfig.systemUser.username;
}
