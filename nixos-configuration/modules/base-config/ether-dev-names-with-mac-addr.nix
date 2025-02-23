{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  boot.initrd.extraFiles."etc/systemd/network/10-use-mac-addr-in-ifnames.link".source =
    config.environment.etc."systemd/network/10-use-mac-addr-in-ifnames.link".source;

  systemd.network.links = {
    "10-use-mac-addr-in-ifnames" = {
      enable = true;
      matchConfig = {
        Type = "ether";
      };
      linkConfig = {
        MACAddressPolicy = "persistent";
        NamePolicy = "mac keep kernel database onboard slot path";
        AlternativeNamesPolicy = "database onboard slot path";
      };
    };
  };
}
