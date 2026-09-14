{
  config,
  lib,
  pkgs,
  utils,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.persistence.enable {
  systemd.tmpfiles.settings = {
    "00-persist-etc-NetworkManager-system-connections" = {
      "/etc/NetworkManager/system-connections"."L+" = {
        argument = "/persistent/state/etc/NetworkManager/system-connections";
      };
      "/persistent/state/etc/NetworkManager/system-connections"."d" = {
        mode = "0700";
        user = "root";
        group = "root";
      };
    };

    "00-persist-var-lib-bluetooth" = {
      "/var/lib/bluetooth"."L+" = {
        argument = "/persistent/state/var/lib/bluetooth";
      };
      "/persistent/state/var/lib/bluetooth"."d" = {
        mode = "0700";
        user = "root";
        group = "root";
      };
    };

    "00-persistent-state-etc-ssh-host-keys" = {
      "/persistent/state/etc/ssh/host-keys"."d" = {
        mode = "0755";
        user = "root";
        group = "root";
      };
    };
  };
}
