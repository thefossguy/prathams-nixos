{ lib, pkgs, forceLtsKernel ? false, supportedFilesystemsSansZFS, ... }:

let
  allSupportedFilesystems = supportedFilesystemsSansZFS ++ [ "zfs" ];
in

lib.mkIf forceLtsKernel {
  boot = {
    # we force them because we want to override values from `nixos-configuration/hosts/hosts-common.nix`
    kernelPackages = lib.mkForce pkgs.linuxPackages;
    initrd.supportedFilesystems = lib.mkForce allSupportedFilesystems;
    supportedFilesystems = lib.mkForce allSupportedFilesystems;

    zfs.allowHibernation = lib.mkForce false;
    zfs.forceImportAll = false;
    zfs.forceImportRoot = false;
  };

  security.pam.zfs.enable = true;
  security.pam.zfs.noUnmount = false;

  # we do this manually, because I have OCD and always divert from "one size fits all"
  services.zfs.autoScrub.enable = lib.mkForce false;
  services.zfs.autoSnapshot.enable = lib.mkForce false;
  services.zfs.trim.enable = lib.mkForce false;

  systemd = {
    timers."custom-zpool-maintainence" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "custom-zpool-maintainence";
        OnCalendar = "Fri *-*-* 00:00:00";
      };
    };

    services."custom-zpool-maintainence" = {
      enable = true;
      path = [ pkgs.linuxPackages.zfs.userspaceTools ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        # TODO: script this lol
        #zpool trim one device
        #zpool scrub
        #zpool trim another device
        #zpool scrub
        exit 1
      '';
    };
  };
}
