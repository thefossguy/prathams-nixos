{
  writeScriptBin,
  lib,
  bash,
  clanker-jail,
  pi-coding-agent,
}:

writeScriptBin "sandboxed-pi-coding-agent" ''
  #!${lib.getExe bash}

  exec ${lib.getExe clanker-jail} --clanker ${lib.getExe pi-coding-agent} "$@"
''
