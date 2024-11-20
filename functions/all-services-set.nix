{ systemType }:
let
  isServer = systemType == "server";
  isDesktop = systemType == "desktop";
  isLaptop = systemType == "laptop";

  systemdTime = {
    timeZone = "Asia/Kolkata";
    # systemd.time format: ${weekday:-} YYYY-MM-DD hour:minute:second
    # The `weekday` must be [non-]abbreviated and not the catch-all `*`.
    Hourly = "*-*-* *:00*00 ${systemdTime.timeZone}";
    Daily = { hour ? "00" }: "*-*-* ${hour}:00:00 ${systemdTime.timeZone}";
    Weekly = { weekday, hour ? "00" }: "${weekday} *-*-* ${hour}:00:00 ${systemdTime.timeZone}";
    Monthly = { weekday, day, hour ? "00" }: "${weekday} *-*-${day} ${hour}:00:00 ${systemdTime.timeZone}";
  };
  mkServiceConfig = { unitName, onCalendar ? "", afterUnits ? [], requiredUnits ? [], ... }: {
    inherit unitName onCalendar afterUnits requiredUnits;
  };
in rec {
  updateNixosFlakeInputs = mkServiceConfig {
    unitName = "update-nixos-flake-inputs";
  };

  customNixosUpgrade = mkServiceConfig {
    unitName = "custom-nixos-upgrade";
    afterUnits = [ "${updateNixosFlakeInputs.unitName}.service" ];
    requiredUnits = customNixosUpgrade.afterUnits;
    onCalendar = if isLaptop then systemdTime.Hourly else (systemdTime.Daily { hour = "05"; });
  };

  continuousBuild = mkServiceConfig {
    unitName = "continuous-build";
    onCalendar = systemdTime.Hourly;
    afterUnits = [ "${customNixosUpgrade.unitName}.service" ];
    requiredUnits = continuousBuild.afterUnits;
  };

  ensureLocalStaticIp = mkServiceConfig {
    unitName = "ensure-local-static-ip";
    afterUnits = [ "network-online.target" ];
    requiredUnits = ensureLocalStaticIp.afterUnits;
  };

  scheduledReboots = mkServiceConfig {
    unitName = "scheduled-reboots";
    onCalendar = systemdTime.Weekly { weekday = "Mon"; hour = "04"; };
    afterUnits = [ "${customNixosUpgrade.unitName}.service" ];
    requiredUnits = scheduledReboots.afterUnits;
  };

  zpoolMaintainenceWeekly = mkServiceConfig {
    unitName = "zpool-maintainence-weekly";
    onCalendar = systemdTime.Weekly { weekday = "Fri"; };
  };

  zpoolMaintainenceMonthly = mkServiceConfig {
    unitName = "zpool-maintainence-monthly";
    onCalendar = systemdTime.Monthly { weekday = "Fri"; day = "01..07"; };
  };

  customHomeManagerUpgrade = mkServiceConfig {
    unitName = "custom-home-manager-upgrade";
    onCalendar = systemdTime.Weekly { weekday = "Mon"; hour = "05"; };
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

  updateRust = mkServiceConfig {
    unitName = "update-rust";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };

  getRedhatCsafVex = mkServiceConfig {
    unitName = "get-redhat-csaf-vex";
    onCalendar = systemdTime.Daily { hour = "05"; };
  };
}
