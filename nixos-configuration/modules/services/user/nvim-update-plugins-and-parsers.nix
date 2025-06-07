{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.nvimUpdatePluginsAndParsers;
in
{
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = {
        RequiredBy = [ "timers.target" ];
      };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
        OnBootSec = "10m";
      };
    };

    services."${serviceConfig.unitName}" = {
      Service = {
        Type = "oneshot";
        ExecStart =
          let
            nvimCmds = "--headless '+Lazy! sync' '+TSUpdate all' '+qa'";
          in
          "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
            set -euf -o pipefail

            if [[ -x ${config.home.homeDirectory}/.nix-profile/bin/nvim ]]; then
                ${config.home.homeDirectory}/.nix-profile/bin/nvim ${nvimCmds}
            elif command -v nvim 1>/dev/null 2>&1; then
                nvim ${nvimCmds}
            fi
          ''}";
      };
    };
  };
}
