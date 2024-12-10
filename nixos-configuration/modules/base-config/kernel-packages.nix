{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  localStdenv = pkgs.stdenv // { isRiscV64 = pkgs.stdenv.hostPlatform.isRiscV; };
  kernelPackages = if nixosSystemConfig.kernelConfig.useLongtermKernel
    then pkgs.linux_6_6
    else (if config.customOptions.socSupport.armSoc == "rk3588"
        then pkgs.linux_testing
        else pkgs.linux_latest);

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = nixosSystemConfig.kernelConfig.useLongtermKernel;
  };

  # Disable ARM64_64K_PAGES pages on LTS kernels because of ZFS.
  enableArm64kPages = (config.networking.hostName == "bheem")
    && (!nixosSystemConfig.kernelConfig.useLongtermKernel) && pkgs.stdenv.isAarch64;
  enableRustSupport = nixosSystemConfig.kernelConfig.enableRustSupport && (
    (localStdenv.isx86_64  && lib.versionAtLeast kernelPackages.version "6.7") ||
    (localStdenv.isAarch64 && lib.versionAtLeast kernelPackages.version "6.9") ||
    (localStdenv.isRiscV64 && lib.versionAtLeast kernelPackages.version "6.10")
  );
in {
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        features.rust = enableRustSupport;
        structuredExtraConfig = with lib.kernel; {
          ARM64_64K_PAGES = if enableArm64kPages then yes else unset;
        };
      };
    }));
  };
}
