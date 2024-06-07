{ config, lib, ... }:

{
  boot.blacklistedKernelModules = lib.mkForce [ "nvidia" ];
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # setting this to 'true' may cause sleep/suspend to fail
    powerManagement.enable = false; # TODO: check this lol
    powerManagement.finegrained = false; # turns off GPU when not in use

    # the other OSS driver (**not "nouveau"**)
    open = true; # TODO: try this out sometime

    nvidiaSettings = true;

    # selects the latest LTS kernel
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # hoping it doesn't ever come to this but just in case I am masochist enough
    # to buy a laptop with an Nvidia dGPU, populate these from the output of
    # 'sudo lshw -c display'
    #prime = {
    #  nvidiaBusId = "PCI:XX:XX:XX";
    #
    #  intelBusId = "PCI:XX:XX:XX"; # Bus ID of the Intel iGPU
    #  amdgpuBusId = "PCI:XX:XX:XX"; # Bus ID of the AMD iGPU
    #};
  };
}
