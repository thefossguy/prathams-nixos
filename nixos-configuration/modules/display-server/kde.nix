{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.displayServer.guiSession == "kde") {
  xdg.portal = {
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  security.pam.services.login.kwallet.enable = true;
  services = {
    desktopManager.plasma6.enable = true;

    displayManager = {
      defaultSession = "plasma";

      sddm = {
        enable = true;
        wayland.enable = lib.mkDefault false; # wayland support is experimental
        enableHidpi = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # these must not be removed so added here to create a build failure
    # if the packages are included in exclusion
    kdePackages.ark # the default compression/decompression utility
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa # music player, use mpv
    filelight # shows disk space
    gwenview # image viewer, use mpv
    khelpcenter
  ];
}
