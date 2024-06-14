{ lib, pkgs, systemUser, ... }:

{
  imports = [ ./base-display-server.nix ];

  xdg.portal = {
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  security.pam.services.${systemUser.username}.kwallet.enable = true;
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

  # enables the Wayland trackpad gestures in Chroimum/Electron
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    cliphist
    wayland-utils
    wl-clipboard

    # these must not be removed so added here to create a build failure
    # if the packages are included in exclusion
    kdePackages.ark # the default compression/decompression utility
    kdePackages.okular # the universal document viewer (good for previews)
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa # music player, use mpv
    gwenview # image viewer, use mpv
    khelpcenter
  ];
}
