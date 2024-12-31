{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.displayServer.guiSession == "hyprland") {
  programs.hyprland.enable = true;
  programs.waybar.enable = true;
  services.hypridle.enable = true;

  security.pam.services.login.kwallet.enable = true;
  security.pam.services.login.kwallet.forceRun = true;

  # lightdm gets enabled by default if no display manager is enabled
  # force disable in case I want to login from the TTY instead of using **any** DM
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      enableHidpi = true;
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl # manage the embedded display's brightness
    cliphist
    grim # screenshot utility
    kdePackages.kwalletmanager
    libnotify # for some reason, this isn't bundled with a notification daemon ('mako' in my case)
    mako # notification daemon
    networkmanagerapplet
    playerctl # for play/pause/next/previous using fn-keys
    slurp # screenshot selection utility
    swaylock-fancy
    swww # setting wallpaper
    wayland-utils
    wl-clipboard
    wofi # app launcher
    xfce.thunar # file manager
    xfce.tumbler # thumbnails for thunar
  ];
}
