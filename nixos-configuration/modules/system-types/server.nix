{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.systemType == "server") {
  boot.kernelParams = [
    # Setting the `hibernate=` cmdline option to `no` is the **same** as
    # putting in the `nohibernate` cmdline option. Not "like", **same**. But
    # the simple reason why `hibernate=no` I prefer over `nohibernate` is
    # **consistency**, and nothing else.
    "hibernate=no"
  ];

  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowSuspend=no
  '';
}
