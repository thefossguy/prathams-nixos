{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.enableLocalLLMSupport {
  imports = [ ./packages.nix ];
}
