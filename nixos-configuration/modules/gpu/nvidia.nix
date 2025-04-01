{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (builtins.elem "nvidia" config.customOptions.gpuSupport) {
  hardware.graphics.extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  services.xserver.videoDrivers =
    if ((builtins.elemAt config.customOptions.gpuSupport 0) == "nvidia") then
      (lib.mkBefore [
        "nvidia"
        "nouveau"
      ])
    else
      [
        "nvidia"
        "nouveau"
      ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = lib.mkForce true;
    #package = config.boot.kernelPackages.nvidia_x11_vulkan_beta_open;

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
