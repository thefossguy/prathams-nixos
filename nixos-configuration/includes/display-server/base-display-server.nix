{ pkgs, ... }:

let
  # more chromium flags in ~/.local/scripts/other-common-scripts/flatpak-manage.sh
  commonChromiumFlags = [
    "--enable-features=TouchpadOverscrollHistoryNavigation" # enable two-finger swipe for forward/backward history navigation
    "--disable-sync-preferences" # disable syncing chromium preferences with a sync account
  ];
in

{
  hardware.opengl.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
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
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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
    foot
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

  nixpkgs.overlays = [
    (self: super: {
      brave = super.brave.override {
        commandLineArgs = commonChromiumFlags;
      };
      ungoogled-chromium = super.ungoogled-chromium.override {
        commandLineArgs = commonChromiumFlags;
      };

      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris ];
      };
      mpv-unwrapped = super.mpv-unwrapped.override {
        ffmpeg = self.ffmpeg-full;
      };
    })
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
