{ ... }:

{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    blacklistedKernelModules = [ "nvidia" ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}
