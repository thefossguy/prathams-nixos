{ pkgs, ... }:

{
  security.rtkit.enable = true;
  sound.enable = true;
  xdg.portal.enable = true;

  services.displayManager.hiddenUsers = [ "root" ];
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";

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
    brave
    fractal
    kdePackages.filelight
    kdePackages.ghostwriter
    kdePackages.keysmith
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
          "Overpass"
          "SourceCodePro"
        ];
      })
    ];
  };
}
