{ lib, nixosSystem, ... }:

{
  imports = [
    ./bootloader-configuration.nix
    ./sysctls.nix
    ./custom-options.nix
    ./misc-configuration.nix
    ./network-configuration.nix
    ./packages/system-packages.nix
    ./modules/services/system-services.nix
    ./user-configuration.nix
    ./virtualisation-configuration.nix
    ./modules/local-nix-cache/nix-conf.nix
  ];

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  system.stateVersion = lib.versions.majorMinor lib.version;

  systemd = {
    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    enableEmergencyMode = false;

    # For more detail, see:
    #   https://0pointer.de/blog/projects/watchdog.html
    watchdog = {
      # systemd will send a signal to the hardware watchdog at half
      # the interval defined here, so every 300s.
      # If the hardware watchdog does not get a signal for 600s,
      # it will forcefully reboot the system.
      runtimeTime = "600s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };
  };

  nix = {
    checkAllErrors = true;
    checkConfig = true;

    gc = {
      automatic = true;
      dates = "Mon *-*-* 00:00:00";
      options = "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      eval-cache = false;
      experimental-features = [ "nix-command" "flakes" ];
      keep-going = false;
      log-lines = 9999;
      max-jobs = 1;
      sandbox = true;
      show-trace = true;
      trusted-users = [ "root" "${nixosSystem.systemUser.username}" ];
    };
  };
}
