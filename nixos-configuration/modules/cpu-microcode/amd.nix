{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.x86CpuVendor == "amd") {
  hardware.cpu.amd.updateMicrocode = true;
}
