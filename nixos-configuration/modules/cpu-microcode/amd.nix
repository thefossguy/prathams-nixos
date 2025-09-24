{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.x86CpuVendor == "amd") {
  hardware.cpu.amd.updateMicrocode = true;
}
