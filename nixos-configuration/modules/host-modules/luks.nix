{
  config,
  lib,
  pkgs,
  utils,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  cryptsetupArgsList =
    lib.lists.optionals config.customOptions.luksDevice.bypassWorkqueues [
      "--perf-no_read_workqueue"
      "--perf-no_write_workqueue"
    ]
    ++ lib.lists.optionals config.customOptions.luksDevice.bypassWorkqueues [
      "--allow-discards"
    ];
  cryptsetupArgs = builtins.concatStringsSep " " cryptsetupArgsList;
in

lib.mkIf (config.customOptions.luksDevice.UUID != null) {
  boot.initrd.luks.devices."${config.customOptions.luksDevice.label}" = {
    device = config.customOptions.luksDevice.blockDevice;
    bypassWorkqueues = config.customOptions.luksDevice.bypassWorkqueues;
  };

  boot.initrd.systemd.services."luks-unlock" = {
    enable = true;
    description = "Derive ${config.customOptions.luksDevice.label} LUKS key from YubiKey challenge-response";

    requiredBy = [ "sysroot.mount" "cryptsetup-pre.target" ];
    wantedBy = [ "initrd.target" "systemd-cryptsetup@${config.customOptions.luksDevice.label}.service" ];
    wants = [ "cryptsetup-pre.target" ];
    before = [ "cryptsetup-pre.target" "blockdev@${utils.escapeSystemdPath "/dev/mapper/${config.customOptions.luksDevice.label}"}.target" "systemd-cryptsetup@${config.customOptions.luksDevice.label}.service" "sysroot.mount" ];
    after = [ "systemd-modules-load.service" "systemd-udev-trigger.service" ];
    requires = [ "${utils.escapeSystemdPath config.customOptions.luksDevice.blockDevice}.device" ];

    unitConfig.DefaultDependencies = "no";

    path = with pkgs; [
      coreutils-full
      yubikey-personalization
      cryptsetup
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -xuf -o pipefail

      for _ in $(seq 120); do
          if ykinfo -2 >/dev/null 2>&1; then
              break
          else
              echo 'Please insert the yubikey to decrypt ${config.customOptions.luksDevice.label}'
              sleep 1
          fi
      done

      echo -n '${config.customOptions.luksDevice.challengeString}' | sha512sum - | cut -d' ' -f1 | ykchalresp -2 -x -i - | cryptsetup open ${cryptsetupArgs} --key-file - ${config.customOptions.luksDevice.blockDevice} ${config.customOptions.luksDevice.label}
    '';
  };
}
