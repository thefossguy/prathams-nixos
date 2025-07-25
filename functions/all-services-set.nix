{ systemType, systemUserUsername }:
let
  isServer = systemType == "server";
  isDesktop = systemType == "desktop";
  isLaptop = systemType == "laptop";

  systemdTime = {
    timeZone = "Asia/Kolkata";
    # systemd.time format: ${weekday:-} YYYY-MM-DD hour:minute:second
    # The `weekday` must be [non-]abbreviated and not the catch-all `*`.
    Hourly =
      {
        minute ? "00",
      }:
      "*-*-* *:${minute}:00 ${systemdTime.timeZone}";
    Daily =
      {
        hour ? "00",
      }:
      "*-*-* ${hour}:00:00 ${systemdTime.timeZone}";
    Weekly =
      {
        weekday,
        hour ? "00",
      }:
      "${weekday} *-*-* ${hour}:00:00 ${systemdTime.timeZone}";
    Monthly =
      {
        weekday,
        day,
        hour ? "00",
      }:
      "${weekday} *-*-${day} ${hour}:00:00 ${systemdTime.timeZone}";
  };
  mkServiceConfig =
    {
      unitName,
      onCalendar ? "",
      afterUnits ? [ ],
      wantedUnits ? [ ],
      requiredUnits ? [ ],
      beforeUnits ? [ ],
      wantedByUnits ? [ ],
      requiredByUnits ? [ ],
      ...
    }:
    {
      inherit
        unitName
        onCalendar
        afterUnits
        wantedUnits
        requiredUnits
        beforeUnits
        wantedByUnits
        requiredByUnits
        ;
    };
in
rec {
  # System services
  caddyServer = mkServiceConfig {
    unitName = "caddy-server";
    afterUnits = [
      "network.target"
      "network-online.target"
    ];
    requiredUnits = [ "network-online.target" ];
    wantedByUnits = [ "multi-user.target" ];
  };

  continuousBuildAndPush = mkServiceConfig {
    unitName = "continuous-build-and-push";
    onCalendar = systemdTime.Hourly { minute = "00,30"; }; # every 30 minutes
    afterUnits = [ "${customNixosUpgrade.unitName}.service" ];
    requiredUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
  };

  customNixosUpgrade = mkServiceConfig {
    unitName = "custom-nixos-upgrade";
    onCalendar = if isLaptop then systemdTime.Hourly { } else (systemdTime.Daily { hour = "04"; });
    afterUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
    requiredUnits = customNixosUpgrade.afterUnits;
  };

  disableIntelPstate = mkServiceConfig {
    unitName = "disable-intel-pstate";
    beforeUnits = [ "default.target" ];
    wantedByUnits = disableIntelPstate.beforeUnits;
  };

  ensureLocalStaticIp = mkServiceConfig {
    unitName = "ensure-local-static-ip";
    afterUnits = [ "network-online.target" ];
    requiredUnits = ensureLocalStaticIp.afterUnits;
  };

  nixGc = mkServiceConfig {
    unitName = "nix-gc";
    beforeUnits = customNixosUpgrade.afterUnits ++ [ "${customNixosUpgrade.unitName}.service" ];
    wantedUnits = nixGc.beforeUnits;
  };

  resetSystemdUserUnits = mkServiceConfig {
    unitName = "reset-systemd-user-units";
    wantedByUnits = [ "multi-user.target" ];
  };

  scheduledReboots = mkServiceConfig {
    unitName = "scheduled-reboots";
    onCalendar = systemdTime.Weekly {
      weekday = "Mon";
      hour = "04";
    };
    afterUnits = [ "${customNixosUpgrade.unitName}.service" ];
    requiredUnits = scheduledReboots.afterUnits;
  };

  signVerifyAndPushNixStorePaths = mkServiceConfig {
    unitName = "sign-verify-and-push-nix-store-paths";
    onCalendar = systemdTime.Hourly { minute = "00,30"; }; # every 30 minutes
    afterUnits = [
      "${customNixosUpgrade.unitName}.service"
      "${updateNixosFlakeInputs.unitName}.service"
    ];
    requiredUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
  };

  updateNixosFlakeInputs = mkServiceConfig {
    unitName = "update-nixos-flake-inputs";
  };

  updateQemuFirmwarePaths = mkServiceConfig {
    unitName = "update-qemu-firmware-paths";
    beforeUnits = [ "libvirtd.socket" ];
    requiredByUnits = [ "libvirtd.socket" ];
  };

  verifyNixStorePaths = mkServiceConfig {
    unitName = "verify-nix-store-paths";
    beforeUnits = [
      "${updateNixosFlakeInputs.unitName}.service"
      "${nixGc.unitName}.service"
      "${scheduledReboots.unitName}.service"
      "${zpoolMaintainenceWeekly.unitName}.service"
      "${zpoolMaintainenceMonthly.unitName}.service"
    ];
    requiredByUnits = [
      # Don't be "RequiredBy" for the `update-nixos-flake-inputs` service
      # or we will need to verify the Nix store every time either
      # `custom-nixos-upgrade` or `continuous-build-and-push` will start.
      "${nixGc.unitName}.service"
      "${scheduledReboots.unitName}.service"
      "${zpoolMaintainenceWeekly.unitName}.service"
      "${zpoolMaintainenceMonthly.unitName}.service"
    ];
    onCalendar = if isLaptop then systemdTime.Hourly { } else (systemdTime.Daily { hour = "04"; });
  };

  zpoolMaintainenceWeekly = mkServiceConfig {
    unitName = "zpool-maintainence-weekly";
    onCalendar = systemdTime.Weekly { weekday = "Fri"; };
  };

  zpoolMaintainenceMonthly = mkServiceConfig {
    unitName = "zpool-maintainence-monthly";
    onCalendar = systemdTime.Monthly {
      weekday = "Fri";
      day = "01..07";
    };
  };

  # User services
  customHomeManagerUpgrade = mkServiceConfig {
    unitName = "custom-home-manager-upgrade";
    onCalendar = systemdTime.Weekly {
      weekday = "Mon";
      hour = "05";
    };
  };

  dotfilesPull = mkServiceConfig {
    unitName = "dotfiles-pull";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  flatpakManage = mkServiceConfig {
    unitName = "flatpak-manage";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  manuallyAutostartLibvirtVms = mkServiceConfig {
    unitName = "manually-autostart-libvirt-vms";
    beforeUnits = [ "default.target" ];
    wantedByUnits = manuallyAutostartLibvirtVms.beforeUnits;
  };

  nvimUpdatePluginsAndParsers = mkServiceConfig {
    unitName = "nvim-update-plugins-and-parsers";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  updateRust = mkServiceConfig {
    unitName = "update-rust";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  # Podman containers (subset of **user** services)
  containerTransmission0x0 = mkServiceConfig {
    unitName = "transmission0x0";
    beforeUnits = [ "default.target" ];
    wantedByUnits = containerTransmission0x0.beforeUnits;
  };
}
