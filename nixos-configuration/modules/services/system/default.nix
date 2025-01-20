{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./continuous-build.nix
    ./copy-nix-store-paths-to-bucket.nix
    ./custom-nixos-upgrade.nix
    ./ensure-local-static-ip.nix
    ./nix-gc.nix
    ./overwrite-bucket-store-info.nix
    ./reset-systemd-user-units.nix
    ./scheduled-reboots.nix
    ./sign-nix-store-paths.nix
    ./sync-nix-build-results.nix
    ./update-nixos-flake-inputs.nix
    ./verify-nix-store-paths.nix
    ./z-upstream-services.nix
    ./zpool-maintainence-monthly.nix
    ./zpool-maintainence-weekly.nix
  ];
}
