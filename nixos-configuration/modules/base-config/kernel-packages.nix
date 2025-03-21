{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  smallPkgs =
    if ((lib.versions.majorMinor pkgsChannels.stable.lib.version) == (lib.versions.majorMinor lib.version)) then
      pkgsChannels.stableSmall
    else
      pkgsChannels.unstableSmall;
  colonelPackages = kernelPackagesSet."${nixosSystemConfig.kernelConfig.kernelVersion}";
  kernelPackagesSet = {
    mainline = smallPkgs.linux_testing;
    stable = smallPkgs.linux_latest;
    longterm = smallPkgs.linux_6_12;
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
  # NixOS doesn't like it when zfs is from non-small channel but the kmod
  # is from a small channel. So override the ZFS package to match the kernel.
  # Otherwise you get this nasty error:
  # ```
  # Failed assertions:
  # The kernel module and the userspace tooling versions are not matching, this is an unsupported usecase.
  # ```
  nixpkgs.overlays = [ (final: prev: { zfs = smallPkgs.zfs; }) ];

  boot = {
    initrd.supportedFilesystems = lib.mkForce supportedFileSystems;
    supportedFilesystems = lib.mkForce supportedFileSystems;

    kernelPackages = lib.mkForce (
      smallPkgs.linuxPackagesFor (
        colonelPackages.override {
          argsOverride = {
            kernelPatches =
              (colonelPackages.kernelPatches or [ ])
              ++ lib.optionals pkgs.stdenv.isx86_64 [
                {
                  name = "EDAC-igen6-Fix-the-flood-of-invalid-error-reports";
                  patch = pkgs.fetchpatch {
                    url = "https://web.git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/patch/drivers/edac/igen6_edac.c?id=267e5b1d267539d9a927dc04aab6f15aca57da92";
                    hash = "sha256-6ySJjfhDo7CyUM8x+Rfgdjmh8bVlfTaWI/v6xAhv5iY=";
                  };
                }
              ];

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
