{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  macAddrIfaceNamesLinkFileBasename = "systemd/network";
  macAddrIfaceNamesLinkFileName = "10-use-mac-addr-in-ifnames.link";
  macAddrIfaceNamesLinkFileContents = ''
    [Match]
    Type=ether

    [Link]
    MACAddressPolicy=persistent
    NamePolicy=mac keep kernel database onboard slot path
    AlternativeNamesPolicy=database onboard slot path
  '';
in
{
  boot.initrd.extraFiles."etc/${macAddrIfaceNamesLinkFileBasename}".source = "${pkgs.etherDevNamesWithMacAddr}";
  environment.etc."${macAddrIfaceNamesLinkFileBasename}/${macAddrIfaceNamesLinkFileName}" = {
    enable = true;
    source = "${pkgs.etherDevNamesWithMacAddr.outPath}/${macAddrIfaceNamesLinkFileName}";
  };

  nixpkgs.overlays = [
    (final: prev: {
      etherDevNamesWithMacAddr = pkgs.stdenvNoCC.mkDerivation {
        pname = "ether-dev-names-with-mac-addr";
        version = "v2024.08";

        phases = [ "buildPhase" ];
        buildPhase = ''
          set -x
          mkdir -vp $out
          cat << EOF > "$out/${macAddrIfaceNamesLinkFileName}"
          ${macAddrIfaceNamesLinkFileContents}
          EOF
          set +x
        '';
      };
    })
  ];
}
