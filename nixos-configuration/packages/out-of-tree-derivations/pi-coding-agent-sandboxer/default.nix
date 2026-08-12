{ python3Packages }:

python3Packages.buildPythonApplication {
  pname = "pi-coding-agent-sandboxer";
  version = "0.1.0";
  format = "other";

  src = ./pi-coding-agent-sandboxer.py;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/pi-coding-agent-sandboxer

    runHook postInstall
  '';

  meta.mainProgram = "pi-coding-agent-sandboxer";
}
