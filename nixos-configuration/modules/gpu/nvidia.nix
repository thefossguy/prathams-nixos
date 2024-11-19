{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (builtins.elem "nvidia" config.customOptions.gpuSupport) {
  boot.blacklistedKernelModules = lib.mkForce [ "nouveau" ];
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidia_x11_vulkan_beta_open;

    # NixOS now defaults to using the open source kernel driver
    # https://github.com/NixOS/nixpkgs/pull/337289
    #open = true;

    # Hoping it doesn't ever come to this but just in case I am masochist enough
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
