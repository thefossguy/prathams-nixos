{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  kernelPackages = kernelPackagesSet."${nixosSystemConfig.kernelConfig.kernelVersion}";
  kernelPackagesSet = {
    mainline = pkgs.linux_testing;
    stable = pkgs.linux_latest;
    longterm = pkgs.linux_6_12;
  };

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = (nixosSystemConfig.kernelConfig.kernelVersion == "longterm");
  };

  enable16kPagesOnAarch64 =
    if
      (
        (nixosSystemConfig.kernelConfig.kernelVersion != "longterm")
        && (config.customOptions.socSupport.armSoc != "rpi4")
        && (!config.customOptions.isIso)
        && pkgs.stdenv.isAarch64
      )
    then
      lib.kernel.yes
    else
      lib.kernel.unset;
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
