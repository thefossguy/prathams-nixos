{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf
  (
    # The module was added before the release of 25.05
    (lib.versionAtLeast (lib.versions.majorMinor lib.version) "25.05")
    && (config.customOptions.displayServer.guiSession == "cosmic")
  )
  {
    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
    ];
  }
