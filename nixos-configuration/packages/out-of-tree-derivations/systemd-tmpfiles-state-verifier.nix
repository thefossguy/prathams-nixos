{
  stdenvNoCC,
  lib,
  testers,
  writeText,
  writeShellScript,
  coreutils-full,
  gawk,
  gnugrep,
  gitMinimal,
  flakeStorePath,
}:

let
  systemdTmpfilesState = writeText "systemd-tmpfiles-state" ''
    /home
    /srv
    /tmp
    /var
    /var/lib/machines
    /var/lib/portables
    /var/tmp
  '';

  innerTestScript = writeShellScript "nixos-test-systemd-tmpfiles-state-verifier-test-script" ''
    export PATH=${
      lib.makeBinPath [
        coreutils-full
        gawk
        gnugrep
      ]
    }:$PATH
    systemd-tmpfiles --cat-config 2>/tmp/systemd-tmpfiles-stderr | grep -i '^q' | awk '{ print $2} ' | sort -i >/tmp/systemd-tmpfiles-stdout
  '';
  systemdTmpfilesStateVerifierTest = testers.runNixOSTest (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      name = "nixos-test-systemd-tmpfiles-state-verifier";
      nodes.machine = { ... }: { };

      testScript = ''
        # Do this so that we build every single time the flake is
        # updated. Regardless of _what_ was modified.
        # flake-store-path: ${flakeStorePath}

        machine.wait_for_unit("multi-user.target")
        machine.succeed("${innerTestScript}")
        machine.copy_from_machine("/tmp/systemd-tmpfiles-stdout")
        machine.copy_from_machine("/tmp/systemd-tmpfiles-stderr")
        machine.shutdown()
      '';
    }
  );
in

stdenvNoCC.mkDerivation {
  name = "systemd-tmpfiles-state-verifier";
  __contentAddressed = false;

  src = null;
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    gitMinimal
    systemdTmpfilesStateVerifierTest
  ];

  installPhase = ''
    cat ${systemdTmpfilesStateVerifierTest}/systemd-tmpfiles-stderr
    git --no-pager diff --color=always ${systemdTmpfilesState} ${systemdTmpfilesStateVerifierTest}/systemd-tmpfiles-stdout
    cp ${systemdTmpfilesStateVerifierTest}/systemd-tmpfiles-stdout "$out"
  '';

  passthru = {
    inherit systemdTmpfilesStateVerifierTest;
  };
}
