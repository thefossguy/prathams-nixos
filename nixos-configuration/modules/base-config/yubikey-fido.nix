{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.enableYubikeySupport {
  boot.kernelModules = [ "usbhid" ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
}
