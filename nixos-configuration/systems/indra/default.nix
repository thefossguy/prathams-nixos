{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.blacklistedKernelModules = [ "snd_hda_codec_hdmi" ]; # we no wants sound over HDMI
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  customOptions = {
    cpuMicrocodeVendor = "intel";
    displayServer.guiSession = "hyprland";
    gpuSupport = [ "intel" ];
    virtualisation.enable = true;
  };
}
