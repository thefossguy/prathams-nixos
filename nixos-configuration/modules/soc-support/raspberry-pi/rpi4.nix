{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rpi4") {
  boot.initrd.availableKernelModules = [
    "vc4"
    "pcie_brcmstb" # for the PCIe Bus
    "reset-raspberrypi" # for the VL805 (PCIe) firmware to load
  ];
} // lib.mkIf (config.customOptions.displayServer.guiSession != "unset") {
  services.xserver.videoDrivers = lib.mkBefore [
    "modesetting" # Prefer the modesetting driver in X11
    "fbdev" # Fallback to fbdev
  ];
}
