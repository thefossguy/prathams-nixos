{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.updateQemuFirmwarePaths;
  userUsername = nixosSystemConfig.coreConfig.systemUser.username;
in
lib.mkIf config.customOptions.virtualisation.enable {
  systemd.services."${serviceConfig.unitName}" = {
    enable = true;
    before = serviceConfig.beforeUnits;
    requiredBy = serviceConfig.requiredByUnits;

    path = with pkgs; [
      bash
      coreutils-full
      findutils
      gnused
    ];

    serviceConfig = {
      User = userUsername;
      Type = "oneshot";
    };

    script = ''
      set -xeuf -o pipefail
      find ${config.customOptions.userHomeDir}/.config/libvirt/qemu -maxdepth 1 -iname '*.xml' | tr '\r\n' ' ' | xargs --no-run-if-empty sed -i 's@/nix/store/.*-qemu-.*/share/qemu/@${config.virtualisation.libvirtd.qemu.package.outPath}/share/qemu/@g'
    '';
  };
}
