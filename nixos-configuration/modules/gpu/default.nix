{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];
}
