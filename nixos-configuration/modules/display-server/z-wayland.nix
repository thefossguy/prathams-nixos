{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf config.customOptions.displayServer.waylandEnabled {
  environment.systemPackages = with pkgs; [
    cliphist
    wayland-utils
    wl-clipboard
  ];
  # Wayland support is experimental
  services.displayManager.sddm.wayland.enable = lib.mkDefault false;
  # Enables the Wayland trackpad gestures in Chroimum/Electron
  environment.sessionVariables.NIXOS_OZONE_WL = lib.mkForce "1";
}
