{
  writeScriptBin,
  lib,
  bash,
  clanker-jail,
  pi-coding-agent,
}:

writeScriptBin "sandboxed-pi-coding-agent" ''
  #!${lib.getExe bash}

  export TMPDIR=$HOME/.tmp/clanker-tmpdir
  exec ${lib.getExe clanker-jail} --clanker ${lib.getExe pi-coding-agent} "$@"
''
