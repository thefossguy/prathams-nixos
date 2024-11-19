{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  kernelPackages = if nixosSystemConfig.kernelConfig.useLongtermKernel
    then pkgs.linux_6_6
    else pkgs.linux_latest;

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = nixosSystemConfig.kernelConfig.useLongtermKernel;
  };

  enableRustSupport = (nixosSystemConfig.kernelConfig.enableRustSupport && (
    (pkgs.stdenv.isx86_64  && lib.versionAtLeast kernelPackages.version "6.7") ||
    (pkgs.stdenv.isAarch64 && lib.versionAtLeast kernelPackages.version "6.9") ||
    ((pkgs.stdenv.isRiscV64 or false) && lib.versionAtLeast kernelPackages.version "6.10")
  ));
in {
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        features.rust = enableRustSupport;
        structuredExtraConfig = with lib.kernel; {
          # Disable ARM64_64K_PAGES pages on LTS kernels because of ZFS.
          #ARM64_64K_PAGES = if ((!nixosSystemConfig.kernelConfig.useLongtermKernel) && pkgs.stdenv.isAarch64) then yes else unset;
        };
      };
    }));
  };
}
