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
  continuousBuildAndPush = mkServiceConfig {
    unitName = "continuous-build-and-push";
    onCalendar = systemdTime.Hourly { };
    afterUnits = [ "${customNixosUpgrade.unitName}.service" ];
    requiredUnits = continuousBuildAndPush.afterUnits;
  };

  customNixosUpgrade = mkServiceConfig {
    unitName = "custom-nixos-upgrade";
    onCalendar = if isLaptop then systemdTime.Hourly { } else (systemdTime.Daily { hour = "04"; });
    afterUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
    requiredUnits = customNixosUpgrade.afterUnits;
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
    onCalendar = continuousBuildAndPush.onCalendar;
    afterUnits = [ "${customNixosUpgrade.unitName}.service" "${updateNixosFlakeInputs.unitName}.service" ];
    requiredUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
  };

  updateNixosFlakeInputs = mkServiceConfig {
    unitName = "update-nixos-flake-inputs";
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
    afterUnits = [ "${dotfilesPull.unitName}.service" ];
    requiredUnits = customHomeManagerUpgrade.afterUnits;
  };

  dotfilesPull = mkServiceConfig {
    unitName = "dotfiles-pull";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  flatpakManage = mkServiceConfig {
    unitName = "flatpak-manage";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  getRedhatCsafVex = mkServiceConfig {
    unitName = "get-redhat-csaf-vex";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  manuallyAutostartLibvirtVms = mkServiceConfig {
    unitName = "manually-autostart-libvirt-vms";
  };

  updateRust = mkServiceConfig {
    unitName = "update-rust";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  podmanInit = mkServiceConfig {
    unitName = "podman-init";
  };
}
