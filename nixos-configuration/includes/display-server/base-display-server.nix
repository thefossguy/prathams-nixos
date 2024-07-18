{ pkgs, ... }:

let
  # more chromium flags in ~/.local/scripts/other-common-scripts/flatpak-manage.sh
  commonChromiumFlags = [
    "--enable-features=TouchpadOverscrollHistoryNavigation" # enable two-finger swipe for forward/backward history navigation
    "--disable-sync-preferences" # disable syncing chromium preferences with a sync account
  ];
  braveWrapped = pkgs.brave.override {
    commandLineArgs = commonChromiumFlags;
  };
  ungoogledChromiumWrapped = pkgs.ungoogled-chromium.override {
    commandLineArgs = commonChromiumFlags;
  };
in

{
  hardware.opengl.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
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
    desktop-file-utils
    fractal # matrix client
    mediainfo-gui
    metadata-cleaner # exif removal
    mpv
    neovide # haz nice neovim animations
    paper-clip # PDF editor
    snapshot # camera
  ] ++ (with pkgs.kdePackages; [
    filelight # visualize disk space
    ghostwriter # markdown editor
    kalk # calculator
  ]) ++ ([
    braveWrapped
    ungoogledChromiumWrapped
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
