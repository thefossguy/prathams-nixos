{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.caddyServer;
  srv_dir = "/srv/thefossguy";
  caddy_dir = "${srv_dir}/caddy";
  caddyfile = "${caddy_dir}/Caddyfile";
  ftp_dir = "${srv_dir}/ftp-files";
  sandboxedCaddy =
    { scriptName, caddyCmd }:
    pkgs.writeScript scriptName ''
      #!${lib.getExe pkgs.caddy}
      set -xeuf -o pipefail

      export XDG_CONFIG_HOME=${srv_dir}

      exec ${lib.getExe' pkgs.util-linux "setpriv"} \
          --landlock-access fs \
          --landlock-rule "path-beneath:read-file,read-dir:${srv_dir}" \
          $(${lib.getExe' pkgs.gnused "sed"} 's|^|--landlock-rule=path-beneath:execute,read-file,read-dir:|' ${
            pkgs.writeClosure [ pkgs.caddy ]
          }) \
          -- ${caddyCmd}
    '';
in
lib.mkIf (config.networking.hostName == "hans") {
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  systemd.services."${serviceConfig.unitName}" = {
    enable = true;
    after = serviceConfig.afterUnits;
    requires = serviceConfig.requiredUnits;
    wantedBy = serviceConfig.wantedByUnits;

    serviceConfig = {
      User = "root";
      Type = "exec";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      Restart = "on-failure";

      # Limit system resources to keep an attack on the web server to
      # cause wreckage to the rest of the system.
      # systemd.resource-control(5)
      CPUWeight = "10";
      CPUQuota = "10%";
      IOWeight = "20";
      MemorySwapMax = 0;
      MemoryMax = "256M";

      ExecStart = sandboxedCaddy {
        scriptName = "caddy-exec-start";
        caddyCmd = "${lib.getExe' pkgs.caddy "caddy"} run --config ${caddyfile}";
      };

      ExecReload = sandboxedCaddy {
        scriptName = "caddy-exec-reload";
        caddyCmd = "${lib.getExe' pkgs.caddy "caddy"} reload --force --config ${caddyfile}";
      };
    };

    preStart = ''
      # we perform our "validation" here
      set -xeuf -o pipefail

      mkdir -vp ${caddy_dir}/ssl/certs
      mkdir -vp ${caddy_dir}/ssl/private
      chmod 700 ${caddy_dir}/ssl/private
      if [[ ! -f ${caddy_dir}/ssl/certs/thefossguy.pem ]] || [[ ! -f ${caddy_dir}/ssl/private/thefossguy-priv.pem ]]; then
          echo 'Either `${caddy_dir}/ssl/certs/thefossguy.pem` or `${caddy_dir}/ssl/private/thefossguy-priv.pem` do not exist'
          echo 'Regenrate them from Cloudflare dashboard'
      fi
      chmod 600 ${caddy_dir}/ssl/private/thefossguy-priv.pem
      if [[ ! -f ${caddyfile} ]]; then
          ${lib.getExe pkgs.curl} "https://gitlab.com/thefossguy/my-caddy-config/-/raw/master/Caddyfile" --output ${caddyfile} || exit 1
      fi
      chown ${nixosSystemConfig.coreConfig.systemUser.username}:root -vR /srv/thefossguy/ftp-files

      mkdir -vp ${ftp_dir}
    '';
  };
}
