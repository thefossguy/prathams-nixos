{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

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

  enable4kPagesOnAarch64 = (
    (nixosSystemConfig.kernelConfig.kernelVersion == "longterm")
    || (config.customOptions.isIso)
    || (config.customOptions.socSupport.armSoc == "rpi4")
  );

  enable16kPagesOnAarch64 =
    (!enable4kPagesOnAarch64)
    && (
      (config.customOptions.socSupport.armSoc == "rk3588")
      || (config.customOptions.socSupport.armSoc == "rpi5")
      || (config.customOptions.socSupport.armSoc == "m4")
    );
in
{
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (
      pkgs.linuxPackagesFor (
        kernelPackages.override {
          argsOverride = {
            structuredExtraConfig = lib.attrsets.optionalAttrs (pkgs.stdenv.isAarch64 && enable16kPagesOnAarch64) {
              ARM64_16K_PAGES = lib.kernel.yes;
            };
          };
        }
      )
    );
  };
}
