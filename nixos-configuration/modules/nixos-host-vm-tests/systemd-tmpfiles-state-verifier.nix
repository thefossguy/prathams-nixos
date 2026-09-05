{
  mkNixosTestVM,
  flakeStorePath,
  nixosConfigurations,
}:

builtins.mapAttrs (
  _: nixosConfiguration:
  let
    nixosTestVM = mkNixosTestVM {
      inherit nixosConfiguration;
      extraModulesToPass = [
        ({ lib, pkgs, ... }: {
          systemd.services.systemd-tmpfiles-state-verifier = {
            wantedBy = [ "multi-user.target" ];
            after = [ "multi-user.target" ];

            path = with pkgs; [
              coreutils-full
              gawk
              gnugrep
            ];

            serviceConfig.Type = "idle";

            script = ''
              systemd-tmpfiles --cat-config 2>/tmp/shared/stderr | grep -i '^q' | awk '{ print $2} ' | sort -i >/tmp/shared/stdout

              systemctl poweroff
            '';
          };
        })
      ];
    };
    systemdTmpfilesState = nixosTestVM.pkgs.writeText "systemd-tmpfiles-state" ''
      /home
      /srv
      /tmp
      /var
      /var/lib/machines
      /var/lib/portables
      /var/tmp
    '';
  in
  nixosTestVM.pkgs.stdenvNoCC.mkDerivation {
    name = "systemd-tmpfiles-state-verifier-${nixosTestVM.config.networking.hostName}";

    __contentAddressed = false;

    src = null;
    dontUnpack = true;

    buildPhase = ''
      # The `config.system.build.vm` script passes `SHARED_DIR` to the VM
      # and gets mounted in the VM at `$TMPDIR/shared`.
      export SHARED_DIR=$(mktemp -d)

      # The test finishes in under ~45 seconds but lets double it + add buffer.
      ${nixosTestVM.lib.getExe' nixosTestVM.pkgs.coreutils-full "timeout"} 120s \
          ${nixosTestVM.lib.getExe nixosTestVM.config.system.build.vm} 2>&1 | \
          ${nixosTestVM.lib.getExe nixosTestVM.pkgs.ansifilter}
    '';

    installPhase = ''
      cat "$SHARED_DIR/stderr"
      diff ${systemdTmpfilesState} "$SHARED_DIR/stdout"
      echo '${flakeStorePath}' > "$out"
    '';

    passthru = { inherit nixosTestVM; };
  }
) nixosConfigurations
