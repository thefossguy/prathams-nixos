{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (builtins.elem "intel" config.customOptions.gpuSupport) {
  hardware.intel-gpu-tools.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-media-driver
    intel-vaapi-driver
    vpl-gpu-rt
  ];
}
