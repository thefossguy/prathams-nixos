{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  colonelPackages = config.customOptions.kernelConfiguration.colonelPackages;
  supportedFileSystems = nixosSystemConfig.kernelConfig.supportedFilesystemsSansZfs // {
    zfs = (config.customOptions.kernelConfiguration.tree == "longterm");
  };

  enable16kPagesOnAarch64 = (pkgs.stdenv.isAarch64 && (!enable4kPagesOnAarch64));
  enable4kPagesOnAarch64 = (
    (config.customOptions.kernelConfiguration.tree == "longterm")
    || (config.customOptions.isIso)
    || (config.customOptions.socSupport.armSoc == "rpi4")
  );
in
{
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (
      pkgs.linuxPackagesFor (
        (colonelPackages.override {
          argsOverride = {
            # Overriding the arguments passed to `buildLinux` goes here

            structuredExtraConfig =
              (colonelPackages.structuredExtraConfig or { })
              // lib.attrsets.optionalAttrs config.customOptions.kernelDevelopment.virt.enable {
                DEBUG_DRIVER = lib.kernel.yes;
                DEBUG_INFO = lib.kernel.yes;
                FRAME_POINTER = lib.kernel.yes;
                GDB_SCRIPTS = lib.kernel.yes;
                RANDOMIZE_BASE = lib.kernel.yes;
                #}
                #// lib.attrsets.optionalAttrs enable16kPagesOnAarch64 {
                #  ARM64_16K_PAGES = lib.kernel.yes;
              };

          };
        }).overrideAttrs
          (oldAttrs: {
            # Overriding parts of the derivation like `postInstall` goes here
          })
      )
    );
  };
}
