{ lib, pkgs, ... }:

{
  imports = [ ./base-display-server.nix ];

  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;
  services.hypridle.enable = true;

  services = {
    displayManager = {
      defaultSession = "hyprland";

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
    blueman
    brightnessctl # manage the embedded display's brightness
    cliphist
    grim # screenshot utility
    kdePackages.kdeconnect-kde
    kdePackages.kdenlive
    kdePackages.okular # the universal document viewer (good for previews)
    libnotify # for some reason, this isn't bundled with a notification daemon ('mako' in my case)
    mako # notification daemon
    networkmanagerapplet
    playerctl # for play/pause/next/previous using fn-keys
    slurp # screenshot selection utility
    swww # setting wallpaper
    wayland-utils
    wl-clipboard
    wofi # app launcher
    xfce.thunar # file manager
  ];
}
