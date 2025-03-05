{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  smallChannel =
    if ((lib.versions.majorMinor pkgsChannels.stable.lib.version) == (lib.versions.majorMinor lib.version)) then
      pkgsChannels.stableSmall
    else
      pkgsChannels.unstableSmall;
  colonelPackages = kernelPackagesSet."${nixosSystemConfig.kernelConfig.kernelVersion}";
  kernelPackagesSet = {
    mainline = smallChannel.linux_testing;
    stable = smallChannel.linux_latest;
    longterm = smallChannel.linux_6_12;
  };

  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = (nixosSystemConfig.kernelConfig.kernelVersion == "longterm");
  };

  enable16kPagesOnAarch64 = (pkgs.stdenv.isAarch64 && (!enable4kPagesOnAarch64));
  enable4kPagesOnAarch64 = (
    (nixosSystemConfig.kernelConfig.kernelVersion == "longterm")
    || (config.customOptions.isIso)
    || (config.customOptions.socSupport.armSoc == "rpi4")
  );
in
{
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (
      smallChannel.linuxPackagesFor (
        colonelPackages.override {
          argsOverride = {
            structuredExtraConfig =
              (colonelPackages.structuredExtraConfig or { })
              // lib.attrsets.optionalAttrs config.customOptions.kernelDevelopment.virt.enable {
                DEBUG_DRIVER = lib.kernel.yes;
                DEBUG_INFO = lib.kernel.yes;
                FRAME_POINTER = lib.kernel.yes;
                GDB_SCRIPTS = lib.kernel.yes;
                RANDOMIZE_BASE = lib.kernel.yes;
              }
              // lib.attrsets.optionalAttrs enable16kPagesOnAarch64 {
                ARM64_16K_PAGES = lib.kernel.yes;
              };
          };
        }
      )
    );
  };
}
