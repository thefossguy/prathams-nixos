{ pkgs, ... }:

{
  nix.settings = {
    keep-derivations = true;
    keep-outputs = true;
  };

  systemd = {
    timers."continuous-build" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "continuous-build";
        OnCalendar = "hourly";
      };
    };

    services."continuous-build" = {
      enable = true;
      after = [ "custom-nixos-upgrade.service" ];
      requires = [ "custom-nixos-upgrade.service" ];
      path = with pkgs; [
        git
        nix
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        pushd /etc/nixos
        export USE_NIX_INSTEAD_OF_NOM=1
        time nix run .#continuousBuild
        popd
      '';
    };
  };
}
