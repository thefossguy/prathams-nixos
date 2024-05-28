{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  security.rtkit.enable = true;
  sound.enable = true;
  xdg.portal.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    displayManager.hiddenUsers = [ "root" ];

    desktopManager = {
      wallpaper = {
        mode = "max"; # center, fill, scale, max, tile
        combineScreens = false; # same wallpaper for all screens
      };
    };

    videoDrivers = [
      "amdgpu"
      "xe"
    ];
  };

  services = {
    printing.enable = true;
    flatpak.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };

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
    fractal
    libsForQt5.filelight
    libsForQt5.ghostwriter
    libsForQt5.keysmith
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
}
