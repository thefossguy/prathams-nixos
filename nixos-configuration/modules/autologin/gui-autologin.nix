{ config, lib, nixosSystem, ... }:

lib.mkIf config.services.xserver.enable {
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = nixosSystem.systemUser.username;
}
