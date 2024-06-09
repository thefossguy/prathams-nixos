{ pkgs, ipv4Address, networkingIface,  ... }:

{
  systemd = {
    services."ensure-local-static-ip" = {
      enable = true;
      wantedBy = [ "basic.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail
        # wait for 120 seconds
        # on top of the 120 seconds that `systemd-networkd-wait-online.service` waits for
        for i in $(seq 0 11); do
            iface_status="$(${pkgs.iproute2}/bin/ip -brief address show ${networkingIface})"

            if [[ "''${iface_status}" =~ UP ]]; then
                if [[ "''${iface_status}" =~ ${ipv4Address} ]]; then
                    exit 0
                else
                    systemctl reboot
                fi
            fi

            sleep 10
        done

        # the networking interface that we needed was not **online**
        # just exit gracefully
        exit 0
      '';
    };
  };
}
