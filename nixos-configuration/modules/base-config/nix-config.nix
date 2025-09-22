{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  fsyncStorePaths = lib.strings.optionalString (lib.versionAtLeast config.nix.package.version "2.25") "fsync-store-paths = true";
  trustedNixUsers = [
    "root"
    nixosSystemConfig.coreConfig.systemUser.username
  ];
in
{
  nix = {
    checkConfig = true;
    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    package = pkgs.nix;

    # disable all "suggested" registries
    settings.flake-registry = lib.mkForce "";
    # setup to pin the nixpkgs input for the nix3 commands
    registry = lib.mkForce {
      nixpkgs.flake = nixosSystemConfig.extraConfig.inputChannel.nixpkgs;
    };

    settings = {
      allowed-users = lib.mkForce trustedNixUsers;
      auto-optimise-store = true;
      connect-timeout = 2;
      # Enabling `eval-cache` on ISOs helps a bit with dry building the NixOS
      # configuration that occurs before filesystem partitioning and formatting.
      # But disable on normal NixOS systems and home-manager. :)
      eval-cache = config.customOptions.isIso or false;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-trusted-public-keys = [ "10.0.0.24:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU=" ];
      extra-substituters = lib.optionals (!(config.customOptions.localCaching.servesNixDerivations or false)) [
        "${lib.strings.optionalString (nixosSystemConfig.extraConfig.canAccessMyNixCache) "http://10.0.0.24"}"
        "https://nix-cache.thefossguy.com"
      ];
      keep-going = false;
      log-lines = 9999;
      max-jobs = 1;
      sandbox = true;
      show-trace = true;
      trusted-users = lib.mkForce trustedNixUsers;
    };

    extraOptions = lib.mkBefore ''
      require-sigs = true
      fallback = true
      ${fsyncStorePaths}
    '';
  };
}
