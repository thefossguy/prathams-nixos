{ config, lib, systemUser, ... }:

lib.mkIf config.services.xserver.enable {
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = systemUser.username;
}
