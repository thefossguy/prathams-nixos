{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.cpuMicrocodeVendor == "amd") {
  hardware.cpu.amd.updateMicrocode = true;
}
