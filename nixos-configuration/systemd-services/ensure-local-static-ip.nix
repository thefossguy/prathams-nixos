{ pkgs, ipv4Address, networkingIface,  ... }:

{
  systemd = {
    services."ensure-local-static-ip" = {
      enable = true;
      requiredBy = [ "basic.target" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        (${pkgs.iproute2}/bin/ip -brief address show ${networkingIface} | \
            ${pkgs.gawk}/bin/awk '{print $3}' | \
            ${pkgs.gawk}/bin/awk -F/ '{print $1}' | \
            ${pkgs.gnugrep}/bin/grep -q ${ipv4Address}) || \
            ${pkgs.systemd}/bin/systemctl reboot
      '';
    };
  };
}
