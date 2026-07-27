{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  nixosHosts =
    (import ../../../functions/nixos-systems.nix {
      linuxSystems = {
        aarch64 = "aarch64-linux";
        riscv64 = "riscv64-linux";
        x86_64 = "x86_64-linux";
      };
    }).systems;
  hostsInLAN = lib.filterAttrs (
    name: value: ((value.extraConfig.canAccessMyNixCache or true) != false) && (value.coreConfig.addrMAC != null)
  ) nixosHosts;
  dhcpServerStaticLeases = lib.attrsets.mapAttrsToList (name: value: {
    MACAddress = value.coreConfig.addrMAC;
    Address = value.coreConfig.ipv4Address;
  }) hostsInLAN;
  dhcpCommonConfig = {
    networkConfig = {
      ConfigureWithoutCarrier = true;
      DHCPServer = true;
      IPMasquerade = "ipv4";
    };
    dhcpServerConfig = {
      PoolOffset = 100;
      PoolSize = 100;
      EmitDNS = true;
      EmitRouter = true;
      DNS = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };
in

lib.mkIf (config.customOptions.isRouter or false) {
  networking = {
    firewall = {
      checkReversePath = lib.mkForce false;
      allowedUDPPorts = [
        67 # client discovery
        68 # communication for DHCP configuration
        53 # local authoritative DNS
      ];
      allowedTCPPorts = [
        53 # local authoritative DNS
      ];
    };

    nftables = {
      tables = {
        "router-fw" = {
          enable = true;
          name = "router-fw";
          family = "inet";
          content = ''
            chain forward {
                # drop everything by default
                type filter hook forward priority filter; policy drop;

                # allow connections that are already established
                ct state { established, related } accept

                # `trusted` <-> `wan`
                iifname "trusted" oifname "wan" accept
                iifname "wan" oifname "trusted" accept

                # `isolated` <-> `wan`
                iifname "isolated" oifname "wan" accept
                iifname "wan" oifname "isolated" accept

                # `trusted` ! `isolated`
                iifname "trusted" oifname "isolated" drop
                iifname "isolated" oifname "trusted" drop

                # log traffic that was dropped
                log prefix "router-fw-drop: " drop
            }
          '';
        };
      };
    };
  };

  systemd.network = {
    links = {
      "10-wan" = {
        matchConfig.MACAddress = "9c:6b:00:22:44:2a";
        linkConfig.Name = "wan";
      };
      "10-lan0" = {
        matchConfig.MACAddress = "a0:10:a2:b6:2c:3d";
        linkConfig.Name = "lan0";
      };
      "10-lan1" = {
        matchConfig.MACAddress = "a0:10:a2:b6:2c:3c";
        linkConfig.Name = "lan1";
      };
      "10-guest0" = {
        matchConfig.MACAddress = "a0:10:a2:b6:19:eb";
        linkConfig.Name = "guest0";
      };
      "10-guest1" = {
        matchConfig.MACAddress = "a0:10:a2:b6:19:ea";
        linkConfig.Name = "guest1";
      };
    };

    networks."20-wan" = {
      matchConfig.Name = "wan";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = false;
      };
      dhcpV4Config = {
        UseDNS = true;
        UseRoutes = true;
      };
    };

    # bridges
    netdevs = {
      "30-trusted" = {
        netdevConfig = {
          Name = "trusted";
          Kind = "bridge";
        };
      };
      "30-isolated" = {
        bridgeConfig.DefaultPVID = "none"; # Disable MAC learning to prevent guest isolation bypass
        netdevConfig = {
          Name = "isolated";
          Kind = "bridge";
        };
      };
    };

    networks = {
      # add ifaces under bridges
      "41-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig.Bridge = "trusted";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "42-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig.Bridge = "trusted";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "43-guest0" = {
        matchConfig.Name = "guest0";
        networkConfig.Bridge = "isolated";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "44-guest1" = {
        matchConfig.Name = "guest1";
        networkConfig.Bridge = "isolated";
        linkConfig.RequiredForOnline = "enslaved";
      };

      # trusted+isolated LANs' DHCP servers
      "45-trusted" = {
        matchConfig.Name = "trusted";
        address = [ "10.0.0.1/24" ];
        dhcpServerConfig.DNS = [ "10.0.0.1" ];
        dhcpServerStaticLeases = dhcpServerStaticLeases;
      }
      // dhcpCommonConfig;
      "46-isolated" = {
        matchConfig.Name = "isolated";
        address = [ "192.168.45.1/24" ];
        dhcpServerConfig.DNS = [ "192.168.45.1" ];
      }
      // dhcpCommonConfig;
    };
  };

  services.nsd = {
    enable = true;
    zones = {
      "nixos-hosts.home.arpa" = {
        data = ''
          $ORIGIN nixos-hosts.home.arpa.
          $TTL 300

          @ IN SOA ns.nixos-hosts.home.arpa. hostmaster.nixos-hosts.home.arpa. (
              2026072801 ; serial
              3600       ; refresh
              600        ; refresh
              86400      ; expire
              300        ; minimum TTL
          )

          @  IN NS ns.nixos-hosts.home.arpa.

          ns IN A ${nixosSystemConfig.extraConfig.gatewayAddr}

          aarch64-linux  IN A ${hostsInLAN.bhim.coreConfig.ipv4Address}
          x86_64-linux  IN A ${hostsInLAN.matsya.coreConfig.ipv4Address}
          local-cache  IN A ${hostsInLAN.chaturvyas.coreConfig.ipv4Address}
        '';
      };
    };
  };
}
