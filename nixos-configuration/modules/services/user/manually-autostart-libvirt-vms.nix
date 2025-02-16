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
      libvirt
    ];
  };
in
lib.mkIf (osConfig.customOptions.virtualisation.enable or false) {
  systemd.user.services."${serviceConfig.unitName}" = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [ appendedPath ];
      ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
        set -xeuf -o pipefail
        VMS_TO_AUTOSTART=( $(virsh --connect qemu:///session list --autostart --state-shutoff --name | tr '\r\n' ' ') )

        for VM_NOT_AUTOSTARTED in "''${VMS_TO_AUTOSTART[@]}"; do
            virsh --connect qemu:///session start "''${VM_NOT_AUTOSTARTED}"
        done
      ''}";
    };
  };
}
