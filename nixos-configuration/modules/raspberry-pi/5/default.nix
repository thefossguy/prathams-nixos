{ lib, pkgs, ... }:

{
  imports = [ ../default.nix ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "nvme" "usbhid" "usb_storage" ];
  };
}
