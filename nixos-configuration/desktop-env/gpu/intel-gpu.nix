{ ... }:

{
  boot.initrd.kernelModules = [ "i915" ];
  services.xserver.videoDrivers = [ "i915" ];
}
