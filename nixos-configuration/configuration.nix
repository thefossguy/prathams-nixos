{ lib, systemUser, ... }:

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

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  system.stateVersion = lib.versions.majorMinor lib.version;

  nix = {
    checkAllErrors = true;
    checkConfig = true;

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
