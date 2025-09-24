{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  networking.nftables.tables = {
    "webserver-lockdown" = {
      name = "webserver-lockdown";
      enable = true;
      family = "inet";

      content = ''
        # https://www.cloudflare.com/ips-v4/#
        set CLOUDFLARE_WHITELISTED_IPV4 {
          type ipv4_addr
          flags interval
          elements = {
            173.245.48.0/20,
            103.21.244.0/22,
            103.22.200.0/22,
            103.31.4.0/22,
            141.101.64.0/18,
            108.162.192.0/18,
            190.93.240.0/20,
            188.114.96.0/20,
            197.234.240.0/22,
            198.41.128.0/17,
            162.158.0.0/15,
            104.16.0.0/13,
            104.24.0.0/14,
            172.64.0.0/13,
            131.0.72.0/22
          }
        }

        # https://www.cloudflare.com/ips-v6/#
        set CLOUDFLARE_WHITELISTED_IPV6 {
          type ipv6_addr
          flags interval
          elements = {
            2400:cb00::/32,
            2606:4700::/32,
            2803:f800::/32,
            2405:b500::/32,
            2405:8100::/32,
            2a06:98c0::/29,
            2c0f:f248::/32
          }
        }

        # Given that my webpages are proxied by Cloudflare, whitelist their
        # "proxy crawlers" and reject every other IP from connecting to
        # port 80 and 443.
        chain cloudflare-whitelist {
          type filter hook input priority 0; policy accept;

          # Allow loopback traffic
          iif "lo" accept

          # Allow established and related connections
          ct state established,related accept

          # Allow ICMP for basic network functionality
          ip protocol icmp accept
          ip6 nexthdr ipv6-icmp accept

          # Whitelist Cloudflare IP ranges for HTTP and HTTPS
          tcp dport { 80, 443 } ip saddr @CLOUDFLARE_WHITELISTED_IPV4 accept
          tcp dport { 80, 443 } ip6 saddr @CLOUDFLARE_WHITELISTED_IPV6 accept

          # Drop all other connections to ports 80 and 443
          tcp dport { 80, 443 } drop
        }
      '';
    };
  };
}
