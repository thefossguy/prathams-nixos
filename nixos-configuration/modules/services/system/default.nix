{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./continuous-build.nix
    ./custom-nixos-upgrade.nix
    ./ensure-local-static-ip.nix
    ./scheduled-reboots.nix
    ./update-nixos-flake-inputs.nix
    ./z-upstream-services.nix
    ./zpool-maintainence-monthly.nix
    ./zpool-maintainence-weekly.nix
  ];
}
