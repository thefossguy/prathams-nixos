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

  programs.light.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    flatpak
    light # for backlight
    mediainfo-gui
    mpv
    neovide
    virt-manager
    wl-clipboard # provides wl-copy and wl-paste (also used by Neovim)
    xclip
    xsel
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
    extraPortals = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
  };

  services.flatpak.enable = true;
}
