{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  # TODO: `s/localStdenv/pkgs.stdenv/g`
  localStdenv = pkgs.stdenv // { isRiscV64 = pkgs.stdenv.hostPlatform.isRiscV; };
in
lib.mkIf (config.customOptions.socSupport.riscvSoc != "unset") {
  assertions = [{
    assertion = (localStdenv.isRiscV64 && nixosSystemConfig.coreConfig.isNixOS);
    message = "The option `customOptions.socSupport.riscvSoc` can only be set on NixOS on 64-bit RISC-V.";
  }];
}
