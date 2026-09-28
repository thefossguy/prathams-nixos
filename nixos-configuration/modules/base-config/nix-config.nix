{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  trustedNixUsers = [
    "root"
    nixosSystemConfig.coreConfig.systemUser.username
  ];
in
{
  nix = {
    checkConfig = true;
    gc.automatic = true;
    gc.options = nixosSystemConfig.extraConfig.nixGcOptions;
    package = pkgs.nix;

    # setup to pin the nixpkgs input for the nix3 commands
    registry = lib.mkForce {
      nixpkgs.flake = nixosSystemConfig.extraConfig.nixpkgs;
    };

    settings = {
      accept-flake-config = lib.mkForce false;
      allowed-users = lib.mkForce trustedNixUsers;
      always-allow-substitutes = true;
      auto-optimise-store = true;
      compress-build-log = true;
      connect-timeout = 30; # affects all network queries
      # Enabling `eval-cache` on ISOs helps a bit with dry building the NixOS
      # configuration that occurs before filesystem partitioning and formatting.
      # But disable on normal NixOS systems and home-manager. :)
      eval-cache = config.customOptions.isIso or false;
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      extra-substituters = [
        "https://nix-cache-r2.thefossguy.com"
      ]
      ++ lib.lists.optionals nixosSystemConfig.extraConfig.canAccessMyNixCache [ "http://10.0.0.24" ];
      extra-trusted-public-keys = [ "10.0.0.24:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU=" ];
      fallback = true;
      flake-registry = lib.mkForce ""; # disable all "suggested" registries
      fsync-metadata = lib.mkForce true;
      fsync-store-paths = lib.mkForce true;
      keep-build-log = true;
      keep-derivations = true;
      keep-env-derivations = true;
      keep-going = true;
      log-lines = 9999;
      max-jobs = if (nixosSystemConfig.coreConfig.systemUser.username == "thefossguy") then 10 else 1;
      max-substitution-jobs = 128;
      require-sigs = true;
      sandbox = lib.mkForce true;
      sandbox-fallback = lib.mkForce false;
      show-trace = true;
      sync-before-registering = lib.mkForce true;
      trusted-users = lib.mkForce trustedNixUsers;
    }
    // lib.optionalAttrs (!(config.customOptions.isIso or false)) { min-free = "10G"; };
  };
}
