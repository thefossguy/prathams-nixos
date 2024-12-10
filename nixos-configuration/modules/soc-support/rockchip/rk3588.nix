{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  boot = {
    kernelModules = [ "dw_hdmi_qp" ];
    kernelPatches = [
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
  };
  hardware.deviceTree = {
    enable = true;
    name = nixosSystemConfig.extraConfig.dtbRelativePath;
  };
}
