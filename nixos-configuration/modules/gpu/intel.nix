{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (builtins.elem "intel" config.customOptions.gpuSupport) {
  services.xserver.videoDrivers = if ((builtins.elemAt config.customOptions.gpuSupport 0) == "intel")
    then (lib.mkBefore [ "xe" ])
    else [ "xe" ];
  hardware.intel-gpu-tools.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-media-driver
    intel-vaapi-driver
    vpl-gpu-rt
  ];
}
