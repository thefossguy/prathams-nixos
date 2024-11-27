{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  fsyncStorePaths = if (lib.versionAtLeast config.nix.package.version "2.25") then "fsync-store-paths = true" else "";
  trustedNixUsers = [ "root" nixosSystemConfig.coreConfig.systemUser.username ];
in {
  nix = {
    checkConfig = true;
    gc.automatic = true;
    gc.options = "--delete-older-than 14d";
    package = pkgs.nix;

    settings = {
      allowed-users = lib.mkForce trustedNixUsers;
      auto-optimise-store = true;
      # Use a single core in the NixOS ISO to prevent choking on low memory machines and VMs.
      cores = if config.customOptions.isIso then 1 else 0;
      # Enabling `eval-cache` on ISOs helps a bit with dry building the NixOS
      # configuration that occurs before filesystem partitioning and formatting.
      # But disable on normal NixOS systems. :)
      eval-cache = config.customOptions.isIso;
      experimental-features = [ "nix-command" "flakes" ];
      keep-going = false;
      log-lines = 9999;
      max-jobs = 1;
      sandbox = true;
      show-trace = true;
      trusted-users = lib.mkForce trustedNixUsers;
    };

    extraOptions = ''
      ${fsyncStorePaths}
      require-sigs = true
    '';
  };
}
