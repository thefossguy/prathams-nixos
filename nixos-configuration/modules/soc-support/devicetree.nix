{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (nixosSystemConfig.extraConfig.dtbRelativePath != null) {
  hardware.deviceTree = {
    enable = true;
    name = nixosSystemConfig.extraConfig.dtbRelativePath;
  };
}
