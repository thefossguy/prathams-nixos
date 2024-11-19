{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf nixosSystemConfig.kernelConfig.useLongtermKernel {
  boot.zfs = {
    # Do not set `boot.zfs.enabled` because the default is not `true` (direct
    # assigned boolean) but it **evaluates to `true`**.
    allowHibernation = lib.mkForce false;
    forceImportAll = false;
    forceImportRoot = false;
  };

  security.pam.services.login.zfs = true;
  security.pam.zfs.enable = true;
  security.pam.zfs.noUnmount = true;

  # we do this manually, because I have OCD and always divert from "one size fits all"
  services.zfs.autoScrub.enable = lib.mkForce false;
  services.zfs.autoSnapshot.enable = lib.mkForce false;
  services.zfs.trim.enable = lib.mkForce false;
}
