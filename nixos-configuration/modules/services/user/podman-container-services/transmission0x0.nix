{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.containerTransmission0x0;
in
lib.mkIf (builtins.elem serviceConfig.unitName osConfig.customOptions.podmanContainers.homelabServices) {
}
