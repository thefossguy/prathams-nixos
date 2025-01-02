{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  waylandEnabled = config.customOptions.displayServer.waylandEnabled;
in lib.mkIf (config.customOptions.displayServer.guiSession != "unset") {
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  security.rtkit.enable = true; # For pulseaudio
  xdg.portal.enable = true;

  services.displayManager.hiddenUsers = [ "root" ];
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  services = {
    blueman.enable = true;
    flatpak.enable = true;
    printing.enable = lib.mkForce false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs = {
    firefox = {
      enable = true;
      preferencesStatus = "user";
      preferences = {
        "accessibility.force_disabled" = 1;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.tabs.insertRelatedAfterCurrent" = false;
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.tabs.warnOnClose" = true;
        "browser.translations.enable" = false;
        "browser.warnOnQuit" = true;
        "dnsCacheEntries" = 2000;
        "extensions.getAddons.discovery.api_url" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.discover.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;
        "extensions.webservice.discoverURL" = false;
        "image.mem.decode_bytes_at_a_time" = 131072;
        "media.block-autoplay-until-in-foreground" = true;
        "media.block-play-until-document-interaction" = true;
        "media.block-play-until-visible" = true;
        "middlemouse.paste" = false;
        "network.dnsCacheExpiration" = 7200;
        "network.dnsCacheExpirationGracePeriod" = 3600;
        "network.ssl_tokens_cache_capacity" = 32768;

        # Removes the "blink" when going fullscreen and removes the unnecessary warning
        # https://old.reddit.com/r/firefox/comments/17hlkhp/what_are_your_must_have_changes_in_aboutconfig/k6o9xiv/
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.delay" = "0";
        "full-screen-api.warning.timeout" = "0";
      };
    };
    virt-manager.enable = config.customOptions.virtualisation.enable;
  };

  environment.systemPackages = (with pkgs; [
    alacritty
    authenticator # alt to Google Authenticator on iOS/Android
    brave
    desktop-file-utils
    emojipick
    foot
    fractal # matrix client
    mediainfo-gui
    metadata-cleaner # exif removal
    #neovide # haz nice neovim animations
    paper-clip # PDF editor
    snapshot # camera
    ungoogled-chromium
  ]) ++ (with pkgs.kdePackages; [
    filelight # visualize disk space
    ghostwriter # markdown editor
    kalk # calculator
    kdeconnect-kde
    okular # the universal document viewer (good for previews)
  ])
  ++ lib.optionals pkgs.stdenv.isx86_64 (with pkgs; [
    kdePackages.kdenlive
    mpv
    tor-browser
  ]);


  fonts = {
    fontDir.enable = true;
    fontDir.decompressFonts = true;
    enableDefaultPackages = true;
    fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
    fontconfig.defaultFonts.monospace = [ "SauceCodePro Nerd Font Mono" ];

    packages = with pkgs; [
      nerd-fonts._0xproto
      nerd-fonts.fira-code
      nerd-fonts.overpass
      nerd-fonts.sauce-code-pro
      noto-fonts-color-emoji
    ];
  };
}
