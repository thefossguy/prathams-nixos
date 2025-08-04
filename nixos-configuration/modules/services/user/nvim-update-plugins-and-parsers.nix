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
lib.mkIf pkgs.stdenv.isLinux {
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
        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
             set -xeuf -o pipefail

           ${config.programs.neovim.finalPackage}/bin/nvim --headless '+Lazy! sync' '+qa'
          ${config.programs.neovim.finalPackage}/bin/nvim --headless '+TSUpdate all' '+qa'``
        ''}";
      };
    };
  };
}
