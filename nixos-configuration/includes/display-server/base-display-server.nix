{ pkgs, ... }:

{
  hardware.opengl.enable = true;
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

  environment.systemPackages = with pkgs; [
    alacritty
    authenticator # alt to Google Authenticator on iOS/Android
    brave
    desktop-file-utils
    fractal # matrix client
    mediainfo-gui
    metadata-cleaner # exif removal
    mpv
    neovide # haz nice neovim animations
    paper-clip # PDF editor
    snapshot # camera
    ungoogled-chromium
  ] ++ (with pkgs.kdePackages; [
    filelight # visualize disk space
    ghostwriter # markdown editor
    kalk # calculator
  ]);

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
