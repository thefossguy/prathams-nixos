{
  writeScriptBin,
  lib,
  bash,
  pi-coding-agent-sandboxer,
  util-linux,
  pi-coding-agent,
}:

writeScriptBin "sandboxed-pi-coding-agent" ''
  #!${lib.getExe bash}

  ${lib.getExe pi-coding-agent-sandboxer} \
      --setpriv-bin ${lib.getExe' util-linux "setpriv"} \
      --pi-bin ${lib.getExe pi-coding-agent} \
      "$@"
''
