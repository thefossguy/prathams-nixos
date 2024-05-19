{ config
, lib
, pkgs
, nixpkgs
, systemUser
, ...
}:

let
  nixpkgsChannelPath = "nixpkgs/channels/nixpkgs";
in

{
  imports = [
    ./bootloader-configuration.nix
    ./custom-options.nix
    ./misc-configuration.nix
    ./network-configuration.nix
    ./packages/system-packages.nix
    ./systemd-services/system-services.nix
    ./user-configuration.nix
    ./virtualisation-configuration.nix
  ];

  environment.etc."${nixpkgsChannelPath}".source = nixpkgs.outPath;

  nix = {
    checkAllErrors = true;
    checkConfig = true;

    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=/etc/${nixpkgsChannelPath}" "nixos-config=/etc/nixos/configuration.nix" "/nix/var/nix/profiles/per-user/root/channels" ];

    gc = {
      automatic = true;
      dates = "*-*-* 23:00:00"; # everyday, at 23:00
      options = "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      eval-cache = false;
      experimental-features = [ "nix-command" "flakes" ];
      keep-going = false;
      log-lines = 9999;
      sandbox = true;
      show-trace = true;
      trusted-users = [ "root" "${systemUser.username}" ];
    };
  };
}
