{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  boot.blacklistedKernelModules = [ "snd_hda_codec_hdmi" ]; # we no wants sound over HDMI
  boot.extraModprobeConfig = "options kvm_intel nested=1";

  # TODO: Remove this on a fresh install
  # Enable kwallet because that was used in my last setup with hyprland.
  security.pam.services.login.kwallet.enable = true;

  customOptions = {
    displayServer.guiSession = "cosmic";
    gpuSupport = [ "intel" ];
    virtualisation.enable = true;
    x86CpuVendor = "intel";
  };
}
