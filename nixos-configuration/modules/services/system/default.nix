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
    ./caddy-server.nix
    ./continuous-build-and-push.nix
    ./custom-nixos-upgrade.nix
    ./disable-intel-pstate.nix
    ./ensure-local-static-ip.nix
    ./nix-gc.nix
    ./reset-systemd-user-units.nix
    ./scheduled-reboots.nix
    ./sign-verify-and-push-nix-store-paths.nix
    ./update-nixos-flake-inputs.nix
    ./update-qemu-firmware-paths.nix
    ./verify-nix-store-paths.nix
    ./z-upstream-services.nix
    ./zpool-maintainence-monthly.nix
    ./zpool-maintainence-weekly.nix
  ];
}
