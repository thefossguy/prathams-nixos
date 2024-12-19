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
          ARM64_16K_PAGES = if (!nixosSystemConfig.kernelConfig.useLongtermKernel) then yes else unset;
        };
      };
    }));
  };
}
