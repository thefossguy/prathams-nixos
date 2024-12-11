{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rpi4") {
  boot.initrd.availableKernelModules = [
    "vc4"
    "pcie_brcmstb" # for the PCIe Bus
    "reset-raspberrypi" # for the VL805 (PCIe) firmware to load
  ];
  services.xserver = lib.mkIf (config.customOptions.displayServer.guiSession != "unset") {
    videoDrivers = lib.mkBefore [
      "modesetting" # Prefer the modesetting driver in X11
      "fbdev" # Fallback to fbdev
    ];
  };
}
