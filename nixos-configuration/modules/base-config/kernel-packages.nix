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

    kernelPatches = lib.optionals (config.customOptions.socSupport.armSoc == "rk3588") [
      {
        name = "0001-arm64-dts-rockchip-make-use-of-HDMI0-PHY-PLL-on-rock-5b";
        patch = (pkgs.fetchurl {
          url = "https://gitlab.collabora.com/hardware-enablement/rockchip-3588/linux/-/commit/0814bb18112d191ef2a986a3cd822a5a556dbf94.patch";
          hash = "sha256-tz/1HIIbqwBMKeDiROCtxylXomsdp5wEbvDyaGbuNSg=";
        });
      }
      {
        name = "0002-improve-rockchip-vop2-display-modes-handling-on-rk3588-hdmi0";
        patch = (pkgs.fetchurl {
          url = "https://lore.kernel.org/lkml/20241116-vop2-hdmi0-disp-modes-v1-0-2bca51db4898@collabora.com/t.mbox.gz";
          hash = "sha256-04G5FebDZzm7A9qopbl455DbYFuMUxSxCwTKYqH0AXc=";
        });
      }
      {
        name = "0003-phy-phy-rockchip-samsung-hdptx-dont-use-of-alias-heiko-st";
        patch = (pkgs.fetchurl {
          url = "https://lore.kernel.org/lkml/20241206103401.1780416-1-heiko@sntech.de/t.mbox.gz";
          hash = "sha256-mAgxW24XGm0Uulf9i0bEdMSD6KVXFYxWlkYwlIaK/5o=";
        });
      }
    ];

    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (kernelPackages.override {
      argsOverride = {
        features.rust = enableRustSupport;
        structuredExtraConfig = with lib.kernel; {
          ARM64_64K_PAGES = if enableArm64kPages then yes else unset;
          DRM_DW_HDMI_QP = module;
          ROCKCHIP_DW_HDMI_QP = yes;
        };
      };
    }));
  };
}
