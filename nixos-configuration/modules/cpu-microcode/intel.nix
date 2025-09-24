{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.x86CpuVendor == "intel") {
  hardware.cpu.intel.updateMicrocode = true;
}
