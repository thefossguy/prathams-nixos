{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ./base-display-server.nix ];

  xdg.portal = {
    configPackages = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
  };

  services.xserver = {
    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
      useQtScaling = true; # for HiDPI
      bigscreen.enable = false; # enable this for HTPC
    };

    displayManager = {
      defaultSession = "plasmawayland";

      sddm = {
        enable = true;
        enableHidpi = true;
        #autologin = {
        #  enable = true;
        #  user = systemUser.username;
        #};
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cliphist
    wayland-utils
    wl-clipboard
  ];

  environment.plasma5.excludePackages = with pkgs; [
    plasma5Packages.elisa # music player, use mpv
    plasma5Packages.gwenview # image viewer, use mpv
    plasma5Packages.khelpcenter

    # DO NOT REMOVE THESE PACKAGES

    # Ark: https://apps.kde.org/en-gb/ark/
    # this is the default compression/decompression utility
    #plasma5Packages.ark # DO NOT REMOVE THIS PACKAGE

    # Okular: https://apps.kde.org/en-gb/okular/
    # this is the universal document viewer (good for previews)
    #plasma5Packages.okular # DO NOT REMOVE THIS PACKAGE
  ];
}
