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
    };

    displayManager = {
      hiddenUsers = [ "root" ];
      sddm = {
        enable = true;
        enableHidpi = true;
        #autologin = {
        #  enable = true;
        #  user = "pratham";
        #};
      };
    };
  };

  sound.enable = true;
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

  programs = {
    firefox.enable = true;
    light.enable = true;
    virt-manager.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty
    mediainfo-gui
    mpv
    neovide
    ungoogled-chromium
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "SourceCodePro"
          "Overpass"
        ];
      })
    ];
  };

  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
  };

  services.flatpak.enable = true;
}
