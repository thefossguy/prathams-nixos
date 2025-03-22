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

  environment.systemPackages = with pkgs; [
    picocom
  ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  hardware.bluetooth.enable = lib.mkForce false;

  customOptions = {
    enablePasswordlessSudo = true;
    gpuSupport = [ "intel" ];
    #localCaching.buildsNixDerivations = true;
    socSupport.disableIntelPstate = true;
    virtualisation.enable = true;
    x86CpuVendor = "intel";
  };
}
