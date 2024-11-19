{ packages }:

let
  mkPkgBinPath = pkg: "${pkg}/bin";
  allPkgsBinPaths = map mkPkgBinPath packages;
  concatenatedPathString = builtins.concatStringsSep ":" allPkgsBinPaths;
in
''PATH="$PATH:${concatenatedPathString}"''
