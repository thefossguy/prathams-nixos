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
    pkgs.etherDevNamesWithMacAddr;

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
            config.environment.etc."systemd/network/10-use-mac-addr-in-ifnames.link".source
          } $out/10-use-mac-addr-in-ifnames.link
          set +x
        '';
      };
    })
  ];
}
