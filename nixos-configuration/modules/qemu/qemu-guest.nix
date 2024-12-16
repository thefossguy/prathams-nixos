{ config, lib, modulesPath, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  services.qemuGuest.enable = true;
}
