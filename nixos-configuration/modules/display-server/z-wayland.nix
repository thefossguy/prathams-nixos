{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.displayServer.waylandEnabled {
  environment.systemPackages = with pkgs; [
    cliphist
    wayland-utils
    wl-clipboard
  ];
  # Enables the Wayland trackpad gestures in Chroimum/Electron
  environment.sessionVariables.NIXOS_OZONE_WL = lib.mkForce "1";
}
