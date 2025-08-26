{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.displayServer.guiSession != "unset") {
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  security.rtkit.enable = true; # For pulseaudio
  xdg.portal.enable = true;

  services.displayManager.hiddenUsers = [ "root" ];
  services.orca.enable = lib.mkForce false;
  services.xserver = {
    enable = true;
    desktopManager.runXdgAutostartIfNone = true;
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
    virt-manager.enable = lib.mkForce config.customOptions.virtualisation.enable;

    firefox = {
      enable = true;
      preferencesStatus = "user";
      preferences = {
        "accessibility.force_disabled" = 1;
        "apz.overscroll.enabled" = false;
        "browser.cache.max_shutdown_io_lag" = 32;
        "browser.ctrlTab.sortByRecentlyUsed" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "browser.tabs.insertAfterCurrent" = true;
        "browser.tabs.insertAfterCurrentExceptPinned" = true;
        "browser.tabs.insertRelatedAfterCurrent" = false; # Open at the far right instead of next to current tab
        "browser.tabs.tabClipWidth" = 999; # Only the active tab has the close button
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.tabs.warnOnClose" = true;
        "browser.translations.enable" = false;
        "browser.uidensity" = 1;
        "browser.urlbar.maxRichResults" = 10;
        "browser.urlbar.suggest.calculator" = 1;
        "browser.warnOnQuit" = true;
        "dnsCacheEntries" = 2000;
        "extensions.getAddons.discovery.api_url" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.discover.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enabled" = false;
        "extensions.screenshots.disabled" = false;
        "extensions.webservice.discoverURL" = false;
        "findbar.highlightAll" = true;
        "identity.fxaccounts.enabled" = true;
        "image.mem.decode_bytes_at_a_time" = 131072;
        "layout.word_select.eat_space_to_next_word" = false;
        "media.autoplay.blocking_policy" = 2;
        "media.block-autoplay-until-in-foreground" = true;
        "media.block-play-until-document-interaction" = true;
        "media.block-play-until-visible" = true;
        "middlemouse.paste" = false;
        "narrate.enabled" = false;
        "network.dnsCacheExpiration" = 7200;
        "network.dnsCacheExpirationGracePeriod" = 3600;
        "network.ssl_tokens_cache_capacity" = 32768;
        "privacy.resistFingerprinting" = true;
        "reader.parse-on-load.enabled" = true;
        "services.sync.prefs.sync.extensions.activeThemeID" = true;
        "sidebar.verticalTabs" = false;
        "ui.systemUsesDarkTheme" = true;
        "widget.non-native-theme.scrollbar.style" = 1;
        "widget.windows.overlay-scrollbars.enabled" = true;

        # Disable checking if Firefox is the default browser or not
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;

        # Smooth scrolling
        "apz.frame_delay.enabled" = false;
        "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 250;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 400;
        "general.smoothScroll.msdPhysics.regularSpringConstant" = 400;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 120;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "0.4";
        "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 5000;
        "mousewheel.min_line_scroll_amount" = 22;
        "toolkit.scrollbox.horizontalScrollDistance" = 4;
        "toolkit.scrollbox.verticalScrollDistance" = 5;

        # Removes the "blink" when going fullscreen and removes the unnecessary warning
        # https://old.reddit.com/r/firefox/comments/17hlkhp/what_are_your_must_have_changes_in_aboutconfig/k6o9xiv/
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.delay" = "0";
        "full-screen-api.warning.timeout" = "0";
      };

      # https://mozilla.github.io/policy-templates/
      policies = {
        DisableAppUpdate = true; # Get updates from Nixpkgs instead
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DefaultDownloadDirectory = "${config.customOptions.userHomeDir}/Downloads";
        DisableBuiltinPDFViewer = false;
        DisableFirefoxAccounts = false;
        DisableFirefoxScreenshots = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "always";
        DisplayMenuBar = "default-off";
        DontCheckDefaultBrowser = true;
        HardwareAcceleration = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        SearchBar = "unified";
        StartDownloadsInTempDirectory = false;

        DNSOverHTTPS = {
          Enabled = true;
          Fallback = true;
          Locked = true;
          # https://github.com/curl/curl/wiki/DNS-over-HTTPS#publicly-available-servers
          ProviderURL = "https://mozilla.cloudflare-dns.com/dns-query";
        };

        EnableTrackingProtection = {
          Cryptomining = true;
          EmailTracking = true;
          Fingerprinting = true;
          Locked = true;
          Value = true;
        };

        PictureInPicture = {
          Enbaled = false;
          Locked = true;
        };

        # Valid strings for installation_mode are
        # - allowed
        # - blocked
        # - force_installed
        # - normal_installed
        ExtensionSettings = {
          # Blocks all addons except the ones specified below
          "*".installation_mode = "blocked";

          # Old Reddit Redirect
          "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
            installation_mode = "force_installed";
          };

          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };

          # Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };

          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };
  };

  environment.systemPackages =
    (
      with pkgs;
      [
        alacritty
        authenticator # alt to Google Authenticator on iOS/Android
        brave
        desktop-file-utils
        emojipick
        foliate # GNOME's book reader
        foot
        #fractal # matrix client
        #handbrake
        #mediainfo-gui
        #meld # GUI side-by-side git diff
        #metadata-cleaner # exif removal
        #obsidian
        paper-clip # PDF editor
        #rpi-imager
        snapshot # camera
        ungoogled-chromium
        video-trimmer # https://gitlab.gnome.org/YaLTeR/video-trimmer
      ]
      ++ lib.optionals config.customOptions.virtualisation.enable [ virt-viewer ]
      ++ lib.optionals pkgs.stdenv.isx86_64 [
        kdePackages.kdenlive
        mpv
        tor-browser
      ]
    )
    ++ (with pkgs.kdePackages; [
      filelight # visualize disk space
      #ghostwriter # markdown editor
      #kalk # calculator
      kdeconnect-kde
      #okular # the universal document viewer (good for previews)
    ])
    ++ (with pkgsChannels.stable; [
      neovide # haz nice neovim animations
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
