{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  kernelPackages = if nixosSystemConfig.kernelConfig.useLongtermKernel
    then pkgs.linux_6_12
    else pkgs.linux_latest;

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = nixosSystemConfig.kernelConfig.useLongtermKernel;
  };
in {
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        structuredExtraConfig = with lib.kernel; {
          # 16K ARM kernels are disabled for a bit.
          #ARM64_16K_PAGES = if (config.customOptions.socSupport.armSoc == "m4") then yes else unset;
        };
      };
    }));
  };
}
