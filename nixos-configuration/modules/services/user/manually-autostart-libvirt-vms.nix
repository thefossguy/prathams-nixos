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
  updateVmFirmwarePaths = "${pkgs.writeShellScript "update-vm-firmware-paths.sh" ''
    #!/usr/bin/env bash
    set -euf -o pipefail

    PATH=$PATH:${pkgs.gawk}/bin:${pkgs.gnused}/bin:${pkgs.jq}/bin
    export PATH

    BUNDLED_QEMU_FIRMWARE_PATH="$(jq --raw-output '.mapping.executable.filename' /var/lib/qemu/firmware/60-edk2-"$(uname -m)".json | awk -F '/' '{print $4}')"
    if ! grep -q "''${BUNDLED_QEMU_FIRMWARE_PATH}" \$1; then
        set -x
        sed -i 's@/nix/store/.*-qemu-.*/share/qemu/@/nix/store/''${BUNDLED_QEMU_FIRMWARE_PATH}/share/qemu/@g' \$1
    fi
    EOF
  ''}";

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

      ExecStartPre = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart-pre.sh" ''
        set -xeuf -o pipefail
        ALL_USER_VMS=( $(virsh --connect qemu:///session list --all --name | tr '\r\n' ' ') )
        for USER_VM in "''${ALL_USER_VMS[@]}"; do
            EDITOR=${updateVmFirmwarePaths} virsh --connect qemu:///session edit
        done
      ''}";

      ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
        set -xeuf -o pipefail

        # Manually append `/run/wrappers/bin` to PATH for `qemu-bridge-helper`
        export PATH=$PATH:/run/wrappers/bin
        virsh --connect qemu:///session list --autostart --state-shutoff --name | xargs --no-run-if-empty --max-args 1 virsh --connect qemu:///session start --force-boot --reset-nvram
      ''}";
    };
  };
}
