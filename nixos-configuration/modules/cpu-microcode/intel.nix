{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.cpuMicrocodeVendor == "intel") {
  hardware.cpu.intel.updateMicrocode = true;
}
