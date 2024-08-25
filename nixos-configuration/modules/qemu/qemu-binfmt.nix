{ pkgs, ... }:

let
  allSystems = [ "aarch64-linux" "riscv64-linux" "x86_64-linux" ];
  emulatedSystems = builtins.filter (x: x != pkgs.stdenv.system) allSystems;
in { boot.binfmt.emulatedSystems = emulatedSystems; }
