{ ... }:

{
  boot = {
    initrd.kernelModules = [ "i915" ];
    blacklistedKernelModules = [ "nvidia" ];
  };
  services.xserver.videoDrivers = [ "i915" ];
}
