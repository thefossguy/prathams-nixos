{ pkgs, ... }:

{
  nix.settings.max-jobs = 1;
  systemd = {
    services."continuous-build" = {
      enable = true;
      after    = [ "update-nixos-flake-inputs.service" ];
      requires = [ "update-nixos-flake-inputs.service" ];
      before   = [ "custom-nixos-upgrade.service" ];
      wantedBy = [ "custom-nixos-upgrade.service" ];
      path = [ pkgs.nix ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "time nix run /etc/nixos.#continuousBuild";
    };
  };
}
