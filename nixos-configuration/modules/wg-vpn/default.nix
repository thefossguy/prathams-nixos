{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./vpn-wg0x0.nix
    ./vpn-wg0x1.nix
    ./vpn-wg0x2.nix
  ];

  system.activationScripts = lib.attrsets.optionalAttrs (config.customOptions.wireguardOptions.enabledVPNs != [ ]) {
    checkWireguardPrivateKey.text = ''
      wireguardInterfaces=( ${
        lib.concatStringsSep " " (map (x: "'${x}'") config.customOptions.wireguardOptions.enabledVPNs)
      } )

      for wgIface in "''${wireguardInterfaces[@]}"; do
          privateKeyFilePath="${config.customOptions.wireguardOptions.wgPrivateKeyDir}/''${wgIface}.priv"
          if [[ ! -f "''${privateKeyFilePath}" ]]; then
              echo "The private key for wireguard interface ''${wgIface} doesn't exist at ''${privateKeyFilePath}." | ${pkgs.systemd}/bin/systemd-cat --identifier wireguard --priority err
              _localstatus=1
          fi

          chown systemd-network:systemd-network "''${privateKeyFilePath}"
          chmod 600 "''${privateKeyFilePath}"
      done
    '';
  };
}
