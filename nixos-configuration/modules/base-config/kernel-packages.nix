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
in
{
  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (
      pkgs.linuxPackagesFor (
        kernelPackages.override {
          argsOverride = {
            structuredExtraConfig =
              with lib.kernel;
              {
              }
              // lib.attrsets.optionalAttrs pkgs.stdenv.isAarch64 {
                ARM64_4K_PAGES =
                  if ((nixosSystemConfig.kernelConfig.kernelVersion == "longterm") || (config.customOptions.isIso)) then yes else no;
                ARM64_16K_PAGES =
                  if
                    (
                      (config.customOptions.socSupport.armSoc == "m4")
                      || (config.customOptions.socSupport.armSoc == "rpi5")
                      || (config.customOptions.socSupport.armSoc == "rk3588")
                    )
                  then
                    yes
                  else
                    no;
                ARM64_64K_PAGES = if (config.customOptions.socSupport.armSoc == "rpi4") then yes else no;
              };
          };
        }
      )
    );
  };
}
