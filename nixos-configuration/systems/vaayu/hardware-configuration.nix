{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E150-2575";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/662384e7-4d66-4f9f-bf71-f6cb2eb20ad5";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f90fe2e2-23eb-4f96-800a-fc278fc3bc73";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/58681bd6-8b77-437e-ad4b-af9cb052cc93";
  };
}
