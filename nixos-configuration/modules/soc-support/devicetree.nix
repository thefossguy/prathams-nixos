{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.attrsets.optionalAttrs (nixosSystemConfig.extraConfig.dtbRelativePath != null) {
  hardware.deviceTree = {
    enable = true;
    name = nixosSystemConfig.extraConfig.dtbRelativePath;
  };
}
