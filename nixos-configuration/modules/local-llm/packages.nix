{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.enableLocalLLMSupport {
  environment.systemPackages = with pkgs; [
    (llama-cpp.override { cudaSupport = true; })
  ];
}
