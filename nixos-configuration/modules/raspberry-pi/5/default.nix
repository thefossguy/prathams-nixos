{ lib, pkgs, ... }:

{
  imports = [ ../common/default.nix ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "nvme"
      "usbhid"
      "usb_storage"
    ];
  };
}
