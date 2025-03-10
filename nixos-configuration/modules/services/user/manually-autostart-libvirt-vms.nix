{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.manuallyAutostartLibvirtVms;
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      bash
      coreutils
      findutils
      libvirt
    ];
  };
in
lib.mkIf (osConfig.customOptions.virtualisation.enable or false) {
  systemd.user.services."${serviceConfig.unitName}" = {
    Install = {
      WantedBy = serviceConfig.wantedByUnits;
    };

    Unit = {
      RequiresMountsFor = [ "%t/libvirt" ];
      Before = serviceConfig.beforeUnits;
    };

    Service = {
      Type = "forking";
      Environment = [ appendedPath ];
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
        set -xeuf -o pipefail

        # Manually append `/run/wrappers/bin` to PATH for `qemu-bridge-helper`
        export PATH=$PATH:/run/wrappers/bin
        virsh --connect qemu:///session list --autostart --state-shutoff --name | xargs --no-run-if-empty --max-args 1 virsh --connect qemu:///session start --force-boot --reset-nvram
      ''}";
    };
  };
}
