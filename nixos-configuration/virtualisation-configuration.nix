{ config, lib, pkgs, systemUser, ... }:

{
  virtualisation = {
    oci-containers.backend = "podman";

    libvirtd = {
      enable = true;
      allowedBridges = [ "virbr0" ];
      onShutdown = "shutdown";

      qemu = {
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMF ];
        package = pkgs.qemu_kvm;
        runAsRoot = false; # not sure about this
        swtpm.enable = true;

        verbatimConfig = ''
          user = "${systemUser.username}"
          group = "${systemUser.username}"
        '';
      };
    };

    podman = {
      enable = true;
      defaultNetwork.settings = { dns_enabled = true; };
      dockerCompat = true;
      dockerSocket.enable = true;
      networkSocket.openFirewall = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };
  };
}
