{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      "share" = {
        "path" = "/heathen_disk";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = nixosSystemConfig.coreConfig.systemUser.username;
        "force group" = nixosSystemConfig.coreConfig.systemUser.username;
      };
    };
  };

  customOptions.x86CpuVendor = "amd";
}
