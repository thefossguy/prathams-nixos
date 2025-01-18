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
    ./copy-nix-store-paths-to-linode.nix
    ./custom-nixos-upgrade.nix
    ./ensure-local-static-ip.nix
    ./nix-gc.nix
    ./reset-systemd-user-units.nix
    ./scheduled-reboots.nix
    ./sign-nix-store-paths.nix
    ./update-nixos-flake-inputs.nix
    ./verify-nix-store-paths.nix
    ./z-upstream-services.nix
    ./zpool-maintainence-monthly.nix
    ./zpool-maintainence-weekly.nix
  ];
}
