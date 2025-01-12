{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  hardware.bluetooth.enable = lib.mkForce false;

  customOptions = {
    x86CpuVendor = "intel";
    enablePasswordlessSudo = true;
    gpuSupport = [ "intel" ];
    localCaching.buildsNixDerivations = true;
    virtualisation.enable = true;
  };
}
