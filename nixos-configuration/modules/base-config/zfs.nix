{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.kernelConfiguration.tree == "longterm") {
  # Do not set `boot.zfs.enabled` because the default is not `true` (direct
  # assigned boolean) but it **evaluates to `true`**. Rather, toggling ZFS is
  # done using the `boot.initrd.supportedFilesystems.zfs` and
  # `boot.supportedFilesystems.zfs`.

  boot.zfs.removeLinuxDRM = true;

  security.pam.services.login.zfs = true;
  security.pam.zfs.enable = true;
  security.pam.zfs.noUnmount = true;

  # we do this manually, because I have OCD and always divert from "one size fits all"
  services.zfs.autoScrub.enable = lib.mkForce false;
  services.zfs.autoSnapshot.enable = lib.mkForce false;
}
