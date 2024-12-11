{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (builtins.elem "amd" config.customOptions.gpuSupport) {
  services.xserver.videoDrivers = if ((builtins.elemAt config.customOptions.gpuSupport 0) == "amd")
    then (lib.mkBefore [ "amdgpu" ])
    else [ "amdgpu" ];
  hardware.amdgpu = {
    amdvlk.enable = true;
    initrd.enable = true;
    opencl.enable = true;
  };
}
