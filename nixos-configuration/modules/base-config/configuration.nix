{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  disableSystemdInIinitrd = config.customOptions.isIso;
in
{
  # The `nixpkgs.buildPlatform.system` option must be set for cross compilation
  # to work. Now, since I wish to perform cross compilation from a Linux
  # machine that is not always going to be an `x86_64-linux`, I am using the
  # value provided by `builtins.currentSystem`. The only catch is, to enable
  # cross compilation, one must pass the `--impure` flag to `nix build`. That
  # is because, Flakes, to ensure purity, do not allow leaking host system
  # information (i.e. `builtins.currentSystem`) into the derivation. Since
  # cross compilation is only used for CI testing and never ships to prod, it
  # is a non-issue. Also, if `--impure` is not passed, this evaluates to the
  # value of the target system, keeping the intentional derivation "pure."
  nixpkgs.buildPlatform.system = builtins.currentSystem or nixosSystemConfig.coreConfig.system;

  boot.initrd.services.lvm.enable = lib.mkOverride 60 false;
  # Prevents a boot error that says:
  # Cannot open access to console, the root account is locked.
  # See sulogin(8) man page for more details.
  boot.initrd.systemd.emergencyAccess = config.users.users."root".hashedPassword;
  boot.initrd.systemd.enable = !disableSystemdInIinitrd;
  boot.runSize = "256m"; # Max so far is 32MB, so 256MB is a **long** shot
  boot.tmp.cleanOnBoot = true; # There really is no reason for /tmp to persist across boots
  customOptions.systemType = nixosSystemConfig.extraConfig.systemType;
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  nixpkgs.hostPlatform.system = nixosSystemConfig.coreConfig.system;
  services.dbus.implementation = "broker";
  services.lvm.enable = lib.mkOverride 60 false;
  system.stateVersion = "25.05";

  # Global defaults that _would_ be overridden from local modules go here.
  boot.zfs.allowHibernation = lib.mkForce false;
  boot.zfs.forceImportAll = lib.mkDefault false;
  boot.zfs.forceImportRoot = lib.mkDefault false;
  hardware.nvidia.modesetting.enable = lib.mkDefault false;
  services.zfs.trim.enable = lib.mkForce false;

  systemd = {
    # Upstream (nixpkgs) has a lot of things broken. Do not enable _yet_.
    #enableStrictShellChecks = true;

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
      runtimeTime = if config.customOptions.isIso then "1800s" else "600s";
      # Forcefully reboot if the final stage of the reboot
      # hangs without progress for more than 30s.
      # For more info, see:
      #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      rebootTime = "30s";
    };
  };

  nix = {
    checkAllErrors = true;
    gc.dates = "Mon *-*-* 00:00:00";
  };
}
