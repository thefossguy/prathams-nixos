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
    (final: prev: {
      kwalletPam = prev.kdePackages.kwallet-pam.overrideAttrs {
        postPatch = ''
          ${prev.kdePackages.kwallet-pam.postPatch or ""}
          sed -i 's/static int force_run = 0;/static int force_run = 1;/' pam_kwallet.c
        '';
      };

      mpv = prev.mpv.override {
        scripts = [ prev.mpvScripts.mpris ];
      };
      mpv-unwrapped = prev.mpv-unwrapped.override {
        ffmpeg = prev.ffmpeg-full;
      };

      brave = prev.brave.override {
        commandLineArgs = commonChromiumFlags;
      };
      ungoogled-chromium = prev.ungoogled-chromium.override {
        commandLineArgs = commonChromiumFlags;
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
