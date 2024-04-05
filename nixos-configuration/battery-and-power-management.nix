{ pkgs, ... }:

{
  powerManagement.enable = true;

  # Linux 6.4 and later is needed for AMD's 'amd-pstate' driver
  # But the LTS kernel offered by NixOS 23.11 (1e2e384c5b7c) is 6.1.y
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services = {
    thermald.enable = true;

    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "AC";
        # switch to battery mode if a battery is detected
        TLP_PERSISTENT_DEFAULT = 0;

        START_CHARGE_THRESH_BAT0 = 50;
        START_CHARGE_THRESH_BAT1 = 50;
        STOP_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT1 = 75;

        WOL_DISABLE = "Y";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        MEM_SLEEP_ON_AC = "s2idle";
        MEM_SLEEP_ON_BAT = "deep";

        CPU_DRIVER_OPMODE_ON_AC = "active";
        CPU_DRIVER_OPMODE_ON_BAT = "active";
        # only available options in "active" operation mode are
        # "performance" and "powersave"
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MAX_PERF_ON_BAT = 50;
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        # enable restoring device state from previous boot
        RESTORE_DEVICE_STATE_ON_STARTUP = 1;

        # disable BT and WWAN (mobile modem) if they are not connected/in-use
        # when laptop switches to battery power
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";

        # unconditionally disable WiFi and WWAN if LAN connects
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        # unconditionally enable WiFi and WWAN if LAN disconnects
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";

        # **never power down PCIe devices**
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "on";

        # disable auto suspend for USB devices
        USB_AUTOSUSPEND = 0;

        # enable TLP's trace mode for debugging
        TLP_DEBUG = "arg bat disk lock nm path pm ps rf run sysfs udev usb";
      };
    };
  };
}
