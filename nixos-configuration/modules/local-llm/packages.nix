{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (llama-cpp.override { cudaSupport = true; })
  ];
}
