{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  displayManager.hiddenUsers = [ "root" ];
  security.rtkit.enable = true;
  sound.enable = true;
  xdg.portal.enable = true;

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
    mediainfo-gui
    mpv
    neovide
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
