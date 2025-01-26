{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  boot = {
    # `boot.loader.efi.canTouchEfiVariables` is set to false by default because
    # `true`  on a system with RO EFI vars fails, causing an error but
    # `false` on a system with RW EFI vars does not fail
    # this is a good default for x86 VMs too
    # so it is always safe to assume that EFI vars cannot be modified
    # but, we can always override it from the host-specific configuration file
    loader.efi.canTouchEfiVariables = lib.mkDefault false;
    blacklistedKernelModules = [
      "nvidia"
      "nouveau"
    ];
    plymouth.enable = lib.mkForce false;

    # present in the initrd but only loaded on-demand
    # **ONLY INCLUDE MODULES NECESSARY TO MOUNT ROT ROOT DEVICE**
    # please do not use this for including drivers for non-storage hardware
    initrd.availableKernelModules = [
      # Storage drivers
      "nvme"
      "usb_storage"
      "usbhid"

      # This is an exception for security and arguably better privacy because of better RNG.
      "jitterentropy_rng"
    ];

    kernelParams =
      [
        # Some of the options were taken from [nix-mineral](https://github.com/cynicsketch/nix-mineral)
        "audit=0" # Disable the audit system to prevent dmesg cluttering
        "debugfs=${if config.customOptions.kernelDevelopment.virt.enable then "on" else "off"}" # Toggle debugfs being mounted or not
        "extra_latent_entropy" # Gather more entropy on boot
        "ignore_loglevel" # Print all messages to the console, helps debug
        "init_on_alloc=1" # Initialize new pages with zeroes
        "init_on_free=1" # Fill freed pages with zeroes
        "iommu.passthrough=0" # Forces DMA to go through IOMMU
        "iommu.strict=1" # DMA unmap operations invalidate IOMMU hardware TLBs synchronously
        "iommu=force" # Force IOMMU isolation
        "mitigations=auto,nosmt" # Apply relevant CPU exploit mitigations
        "module.sig_enforce=1" # Load only signed modules
        "no_console_suspend" # Never suspend/hibernate the console
        "page_alloc.shuffle=1" # Enable page randomisation
        "pti=on" # Mitigates Meltdown, some KASLR bypasses
        "random.trust_bootloader=off" # Do not trust bootloader provided RNG seed
        "random.trust_cpu=off" # Do not trust CPU's RNG
        "randomize_kstack_offset=on" # Enable kernel stack offset randomisation
        "slab_nomerge" # Disable merging of slabs with similar size
        "vsyscall=none" # Disable fixed address syscalls; mostly used by old glibc

        "boot.shell_on_fail" # Enable recovery shell if boot fails
        "boot.trace" # Use `set -x` to trace the shell scripts

        "fsck.mode=auto"
        "fsck.repair=preen"

        "plymouth.enable=0"
        "rd.plymouth=0"
      ]
      ++ lib.optionals pkgs.stdenv.isx86_64 [
        "ia32_emulation=0" # Disable multilib/32-bit applications
      ]
      ++ lib.optionals (config.customOptions.x86CpuVendor == "amd") [
        "amd_iommu=force_isolation" # Force IOMMU isolation with AMD's IOMMU driver
        "amd_iommu=on" # Enable AMD's IOMMU driver
      ]
      ++ lib.optionals (config.customOptions.x86CpuVendor == "intel") [
        "intel_iommu=on" # Enable Intel's IOMMU driver
      ]
      ++ lib.optionals config.customOptions.kernelDevelopment.virt.enable [ "nokaslr" ];

    loader = {
      timeout = lib.mkForce 10;
      systemd-boot = {
        enable = lib.mkForce true;
        editor = lib.mkForce false;
      };
    };
  };
}
