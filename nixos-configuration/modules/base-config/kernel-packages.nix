{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  kernelPackages = kernelPackagesSet."${nixosSystemConfig.kernelConfig.kernelVersion}";
  kernelPackagesSet = {
    lts = pkgs.linux_6_12;
    latest = pkgs.linux_latest;
    testing = pkgs.linux_testing;
  };

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = (nixosSystemConfig.kernelConfig.kernelVersion == "lts");
  };

  enable16kPagesOnAarch64 = if ((nixosSystemConfig.kernelConfig.kernelVersion != "lts") && pkgs.stdenv.isAarch64)
    then lib.kernel.yes
    else lib.kernel.unset;
in {
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        structuredExtraConfig = with lib.kernel; {
          ARM64_16K_PAGES = enable16kPagesOnAarch64;
        };
      };
    }));
  };
}
