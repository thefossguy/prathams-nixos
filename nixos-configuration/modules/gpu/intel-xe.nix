{ pkgs, ... }:

{
  hardware.opengl.extraPackages = [
    pkgs.intel-media-driver
  ];
}
