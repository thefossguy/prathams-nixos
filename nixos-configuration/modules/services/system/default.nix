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
    ./continuous-build-and-push.nix
    ./custom-nixos-upgrade.nix
    ./ensure-local-static-ip.nix
    ./nix-gc.nix
    ./reset-systemd-user-units.nix
    ./scheduled-reboots.nix
    ./sign-verify-and-push-nix-store-paths.nix
    ./update-nixos-flake-inputs.nix
    ./update-qemu-firmware-paths.nix
    ./z-upstream-services.nix
    ./zpool-maintainence-monthly.nix
    ./zpool-maintainence-weekly.nix
  ];
}
