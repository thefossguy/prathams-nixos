{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.ensureLocalStaticIp;
in
{
  systemd.services."${serviceConfig.unitName}" = {
    enable = true;
    wantedBy = [ "basic.target" ];
    after = serviceConfig.afterUnits;
    requires = serviceConfig.requiredUnits;

    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };

    script =
      let
        netIface =
          if config.customOptions.virtualisation.enableVirtualBridge then
            "virbr0"
          else
            nixosSystemConfig.coreConfig.primaryNetIface;
      in
      ''
        set -xuf -o pipefail

        DHCP_UNFUCK_MAX_ATTEMPTS='5'
        DHCP_UNFUCK_LOG_DIR='/var/${serviceConfig.unitName}'
        DHCP_UNFUCK_LOG_FILE='rebootsSinceDhcpFuckUp'
        DHCP_UNFUCK_LOG_FILE_PATH="''${DHCP_UNFUCK_LOG_DIR}/''${DHCP_UNFUCK_LOG_FILE}"

        [[ ! -d "''${DHCP_UNFUCK_LOG_DIR}" ]] && mkdir -p "''${DHCP_UNFUCK_LOG_DIR}"

        if [[ ! -f "''${DHCP_UNFUCK_LOG_FILE_PATH}" ]]; then
            echo '0' > "''${DHCP_UNFUCK_LOG_FILE_PATH}"
        fi
        DHCP_UNFUCK_CUR_ATTEMPT="$(cat "''${DHCP_UNFUCK_LOG_FILE_PATH}")"

        # If the networking interface starts with a 'w', it's WiFi and will never
        # get a static IP. So we exclude the check entirely.
        if echo '${netIface}' | grep -q '^w'; then
            exit 0
        fi

        # Wait for 120 seconds, on top of the 120 seconds that
        # `systemd-networkd-wait-online.service` waits for.
        for _ in $(seq 0 11); do
            iface_status="$(${pkgs.iproute2}/bin/ip -brief address show ${netIface})"

            if [[ "''${iface_status}" =~ 'UP' ]]; then
                if [[ "''${iface_status}" =~ ${nixosSystemConfig.coreConfig.ipv4Address} ]]; then
                    if [[ "''${DHCP_UNFUCK_CUR_ATTEMPT}" -ne 0 ]]; then
                        echo '0' > "''${DHCP_UNFUCK_LOG_FILE_PATH}"
                    fi
                    exit 0
                else
                    if [[ "''${DHCP_UNFUCK_CUR_ATTEMPT}" -lt "''${DHCP_UNFUCK_MAX_ATTEMPTS}" ]]; then
                        echo "$(( "''${DHCP_UNFUCK_CUR_ATTEMPT}" + 1 ))" > "''${DHCP_UNFUCK_LOG_FILE_PATH}"
                        systemctl reboot
                    else
                        exit 1
                    fi
                fi
            fi

            # The network interface was not up. We wait a bit.
            sleep 10
        done

        # The networking interface is either:
        # 1. Not online yet
        # 2. Was renamed to something else by systemd :(
        # So, just exit gracefully.
        exit 0
      '';
  };
}
