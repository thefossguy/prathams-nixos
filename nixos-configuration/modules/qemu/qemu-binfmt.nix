{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  allSystems = [ "aarch64-linux" "riscv64-linux" "x86_64-linux" ];
  emulatedSystems = builtins.filter (x: x != pkgs.stdenv.system) allSystems;
in
lib.mkIf config.customOptions.enableQemuBinfmt {
  boot.binfmt.emulatedSystems = emulatedSystems;
  environment.systemPackages = with pkgs; [
    qemu_full
  ];
}
