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
  editorVar = "/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/scripts/update-vm-firmware-paths.sh";
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      bash
      coreutils
      findutils
      gawk
      jq
      libvirt
    ];
  };
in
lib.mkIf (osConfig.customOptions.virtualisation.enable or false) {
  systemd.user.services."${serviceConfig.unitName}" = {
    Install = {
      WantedBy = [ "default.target" ];
    };

    Unit = {
      RequiresMountsFor = "%t/libvirt";
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };

    Service = {
      Type = "forking";
      Environment = [ appendedPath ];
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
        set -xeuf -o pipefail

        BUNDLED_QEMU_FIRMWARE_PATH="$(jq --raw-output '.mapping.executable.filename' /var/lib/qemu/firmware/60-edk2-"$(uname -m)".json | awk -F '/' '{print $4}')"

        cat << EOF > ${editorVar}
        set -xeuf -o pipefail
        sed -i 's@/nix/store/.*-qemu-.*/share/qemu/@/nix/store/''${BUNDLED_QEMU_FIRMWARE_PATH}/share/qemu/@g' \$1
        EOF

        echo '--------------------------------------------------------------------------------'
        cat ${editorVar}
        echo '--------------------------------------------------------------------------------'

        chmod +x ${editorVar}
        EDITOR=${editorVar}
        export EDITOR

        virsh --connect qemu:///session list --all --name | xargs --no-run-if-empty --max-args 1 virsh --connect qemu:///session edit

        # Manually append `/run/wrappers/bin` to PATH for `qemu-bridge-helper`
        export PATH=$PATH:/run/wrappers/bin
        virsh --connect qemu:///session list --autostart --state-shutoff --name | xargs --no-run-if-empty --max-args 1 virsh --connect qemu:///session start --force-boot --reset-nvram
      ''}";
    };
  };
}
