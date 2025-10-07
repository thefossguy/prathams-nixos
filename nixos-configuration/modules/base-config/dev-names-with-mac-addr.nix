{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  emptyFile = "${pkgs.writeText "empty-file" ""}";
in

{
  boot.initrd.extraFiles = {
    "etc/systemd/network/10-use-mac-addr-in-ifnames-ether.link".source = pkgs.etherDevNamesWithMacAddr;
    "etc/systemd/network/10-use-mac-addr-in-ifnames-wlan.link".source =
      if config.customOptions.enableWlanPersistentNames then pkgs.etherDevNamesWithMacAddr else emptyFile;
  };

  systemd.network.links = {
    "20-use-mac-addr-in-ifnames-ether" = {
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

    "20-use-mac-addr-in-ifnames-wlan" = lib.mkIf config.customOptions.enableWlanPersistentNames {
      enable = true;
      matchConfig = {
        Type = "wlan";
      };
      linkConfig = {
        MACAddressPolicy = "persistent";
        NamePolicy = "mac keep kernel database onboard slot path";
        AlternativeNamesPolicy = "database onboard slot path";
      };
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      etherDevNamesWithMacAddr = pkgs.stdenvNoCC.mkDerivation {
        pname = "ether-dev-names-with-mac-addr";
        version = "v2024.08";

        phases = [ "buildPhase" ];
        buildPhase = ''
          set -x
          mkdir -p $out
          cp ${
            config.environment.etc."systemd/network/10-use-mac-addr-in-ifnames-ether.link".source
          } $out/10-use-mac-addr-in-ifnames-ether.link
          set +x
        '';
      };

      wlanDevNamesWithMacAddr = pkgs.stdenvNoCC.mkDerivation {
        pname = "wlan-dev-names-with-mac-addr";
        version = "v2025.04";

        phases = [ "buildPhase" ];
        buildPhase = ''
          set -x
          mkdir -p $out
          cp ${
            config.environment.etc."systemd/network/10-use-mac-addr-in-ifnames-wlan.link".source
          } $out/10-use-mac-addr-in-ifnames-wlan.link
          set +x
        '';
      };
    })
  ];
}
