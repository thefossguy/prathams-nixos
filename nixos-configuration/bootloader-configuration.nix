{ lib, nixosSystem, ... }:

{
  boot = {
    # `boot.loader.efi.canTouchEfiVariables` is set to false by default because
    # `true`  on a system with RO EFI vars fails, causing an error but
    # `false` on a system with RW EFI vars does not fail
    # this is a good default for x86 VMs too
    # so it is always safe to assume that EFI vars cannot be modified
    # but, we can always override it from the host-specific configuration file
    loader.efi.canTouchEfiVariables = false;
    blacklistedKernelModules = [ "nvidia" ];
    plymouth.enable = lib.mkForce false;
    supportedFilesystems = nixosSystem.supportedFilesystemsSansZFS;

    # present in the initrd but only loaded on-demand
    # **ONLY INCLUDE MODULES NECESSARY TO MOUNT ROT ROOT DEVICE**
    # please do not use this for including drivers for non-storage hardware
    initrd.availableKernelModules = [ "nvme" "usb_storage" "usbhid" ];

    kernelParams = [
      "audit=0"
      "ignore_loglevel"

      "boot.shell_on_fail"

      "fsck.mode=auto"
      "fsck.repair=preen"

      "plymouth.enable=0"
      "rd.plymouth=0"

      "no_console_suspend"
    ];

    loader = {
      timeout = lib.mkForce 10;
      systemd-boot = {
        enable = lib.mkForce true;
        editor = lib.mkForce false;
      };
    };
  };
}
