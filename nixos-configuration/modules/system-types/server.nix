{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.systemType == "server") {
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowSuspend=no
  '';
}
