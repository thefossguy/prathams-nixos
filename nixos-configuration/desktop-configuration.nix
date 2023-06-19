{ config, pkgs, ... }:

{
  # KDE Plasma 5 on Wayland
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";

    desktopManager = {
      wallpaper = {
        mode = "max"; # center, fill, scale, max, tile
        combineScreens = false; # same wallpaper for all screens
      };
      plasma5 = {
        enable = true;
        runUsingSystemd = true;
        useQtScaling = true; # for HiDPI
        bigscreen.enable = false; # enable this for HTPC
      };
    };

    displayManager = {
      hiddenUsers = [ "thefossguy" "root" ];
      sddm = {
        enable = true;
        enableHidpi = true;
        defaultSession = "plasmawayland";
        #autologin = {
        #  enable = true;
        #  user = "pratham";
        #};
      };
    };

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      ##pkgs.plasma5Packages.ark # DO NOT REMOVE THIS
      ##pkgs.plasma5Packages.okular # DO NOT REMOVE THIS
      pkgs.plasma5Packages.elisa # music player, use mpv
      pkgs.plasma5Packages.gwenview # image viewer, use mpv
      pkgs.plasma5Packages.khelpcenter
    ];

    #windowManager = {
    #  default = "bspwm";
    #  bspwm = {
    #    enable = true;
    #    configFile = "/home/pratham/.config/bspwm/bspwmrc";
    #    sxhkd.configFile = "/home/pratham/.config/sxhkd/sxhkdrc";
    #  };
    #};
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  services.printing.enable = true;

  programs.light.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    neovide
    nerdfonts # provides (Sauce|Source)CodePro Nerd Font

    light # for backlight

    mediainfo-gui

    wl-clipboard # provides wl-copy and wl-paste (also used by Neovim)

    flatpak
  ];

  xdg.portal.enable = true;
  services.flatpak.enable = true;
}
