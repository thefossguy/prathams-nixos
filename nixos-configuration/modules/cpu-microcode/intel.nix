{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.x86CpuVendor == "intel") {
  hardware.cpu.intel.updateMicrocode = true;
}
