{ pkgs, ... }:

{
  nix.settings.max-jobs = 1;
  systemd = {
    services."continuous-build" = {
      enable = true;
      after    = [ "custom-nixos-upgrade.service" ];
      requires = [ "custom-nixos-upgrade.service" ];
      path = [ pkgs.nix ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "time nix run /etc/nixos.#continuousBuild";
    };
  };
}
