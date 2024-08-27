{ config, pkgs, nixosSystem, ... }:
let
  serviceName = "ensure-local-static-ip";
  dhcpUnfuckAttemptsLogFileDir = "/var/${serviceName}";
  dhcpUnfuckAttemptsLogFileName = "rebootsSinceDhcpFuckUp";
  dhcpUnfuckAttemptsLogFileFilePath = "${dhcpUnfuckAttemptsLogFileDir}/${dhcpUnfuckAttemptsLogFileName}";
  maxRebootsAttemptsAllowed = 5;
in {
  systemd = {
    services."${serviceName}" = {
      enable = true;
      wantedBy = [ "basic.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script =
        let
          netIface = if (config.custom-options.runsVirtualMachines or false)
            then "virbr0"
            else "${nixosSystem.networkingIface}";
        in ''
          set -xuf -o pipefail

          # good initial value
          DHCP_UNFUCK_ATTEMPTS='0'
          [[ ! -d ${dhcpUnfuckAttemptsLogFileDir} ]] && mkdir -p ${dhcpUnfuckAttemptsLogFileDir}

          if [[ ! -f ${dhcpUnfuckAttemptsLogFileFilePath} ]]; then
              echo '0' > ${dhcpUnfuckAttemptsLogFileFilePath}
          else
              DHCP_UNFUCK_ATTEMPTS="$(cat ${dhcpUnfuckAttemptsLogFileFilePath})"
          fi

          # if '${netIface}' starts with a `w`, we exclude the check entirely
          if echo '${netIface}' | grep ^w > /dev/null; then
              exit 0
          fi

          # wait for 120 seconds
          # on top of the 120 seconds that `systemd-networkd-wait-online.service` waits for
          for i in $(seq 0 11); do
              iface_status="$(${pkgs.iproute2}/bin/ip -brief address show ${netIface})"

              if [[ "''${iface_status}" =~ UP ]]; then
                  if [[ "''${iface_status}" =~ ${nixosSystem.ipv4Address} ]]; then
                      if [[ "''${DHCP_UNFUCK_ATTEMPTS}" -ne 0 ]]; then
                          echo '0' > ${dhcpUnfuckAttemptsLogFileFilePath}
                      fi
                      exit 0
                  else
                      if [[ "''${DHCP_UNFUCK_ATTEMPTS}" -lt ${toString maxRebootsAttemptsAllowed} ]]; then
                          echo "$(( "''${DHCP_UNFUCK_ATTEMPTS}" + 1 ))" > ${dhcpUnfuckAttemptsLogFileFilePath}
                          systemctl reboot
                      else
                          exit 1
                      fi
                  fi
              fi

              # iface wasn't UP, wait
              sleep 10
          done

          # the networking interface that we needed was **not online** :(
          # just exit gracefully
          exit 0
        '';
    };
  };
}
