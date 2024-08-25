{ ... }:

{
  imports = [
    ../common/default.nix
    ./gpu.nix
  ];

  boot.initrd.availableKernelModules = [
    "usbhid"
    "usb_storage"

    "vc4"

    "pcie_brcmstb" # for the PCIe Bus
    "reset-raspberrypi" # for the VL805 (PCIe) firmware to load
  ];

}
