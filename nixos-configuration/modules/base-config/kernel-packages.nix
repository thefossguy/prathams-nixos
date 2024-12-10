{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  localStdenv = pkgs.stdenv // { isRiscV64 = pkgs.stdenv.hostPlatform.isRiscV; };
  kernelPackages = if nixosSystemConfig.kernelConfig.useLongtermKernel
    then pkgs.linux_6_6
    else pkgs.linux_latest;

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = nixosSystemConfig.kernelConfig.useLongtermKernel;
  };

  # Disable ARM64_64K_PAGES pages on LTS kernels because of ZFS.
  enableArm64kPages = (config.networking.hostName == "bheem")
    && (!nixosSystemConfig.kernelConfig.useLongtermKernel) && pkgs.stdenv.isAarch64;
in {
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        structuredExtraConfig = with lib.kernel; {
          ARM64_64K_PAGES = if enableArm64kPages then yes else unset;
        };
      };
    }));
  };
}
