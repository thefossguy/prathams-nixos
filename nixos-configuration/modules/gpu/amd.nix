{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (builtins.elem "amd" config.customOptions.gpuSupport) {
  services.xserver.videoDrivers = lib.mkBefore [ "modesetting" ];
  hardware.amdgpu = {
    amdvlk.enable = true;
    initrd.enable = true;
    opencl.enable = true;
  };
}
