{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf config.customOptions.kernelDevelopment.virt.enable {
}
