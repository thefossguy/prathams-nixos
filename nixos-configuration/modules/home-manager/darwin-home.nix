{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf pkgs.stdenv.isDarwin {
  # TODO: Install the following with homebrew
  # - bash
  # - homebrew/cask/mpv
  # - utm

  home.homeDirectory = "/Users/${nixosSystemConfig.coreConfig.systemUser.username}";

  # Sourcing the bash completion offered by nixpkgs because macOS will not provide bash in the future.
  xdg.dataFile = {
    "nix-bash/bash_completion.sh" = {
      enable = true;
      executable = true;
      source = "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh";
    };
  };
  # home-manager does not need to overwrite these files
  xdg.configFile = {};
  home.file = {
    ".bash_profile".enable = false;
    ".bashrc".enable = false;
    ".profile".enable = false;
  };

  targets.darwin = {
    currentHostDefaults = { "com.apple.controlcenter".BatteryShowPercentage = true; };
    defaults = {
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      "com.apple.Safari" = {
        AutoFillCreditCardData = false;
        AutoFillPasswords = false;
        AutoOpenSafeDownloads = false;
        IncludeDevelopMenu = true;
        ShowOverlayStatusBar = true;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.dock" = {
        expose-group-apps = false;
        size-immutable = false;
        tilesize = 32;
      };
    };
    # https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html
    keybindings = {
      "^Uf702" = "moveWordLeft:"; # Ctrl-<Left>
      "^Uf703" = "moveWordRight:"; # Ctrl-<Right>
    };
  };

  programs = {
    alacritty.enable = true;
  };
}
