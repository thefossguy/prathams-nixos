{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  hardware.bluetooth.enable = lib.mkForce false;

  customOptions = {
    cpuMicrocodeVendor = "intel";
    enablePasswordlessSudo = true;
    enableQemuBinfmt = true;
    gpuSupport = [ "intel" ];
    virtualisation.enable = true;
  };
}
