{ config, lib, pkgs, nixosSystem, ... }:

lib.mkIf (config.custom-options.runsVirtualMachines or false) {
  environment.systemPackages = with pkgs; [ bridge-utils ];

  virtualisation = {
    oci-containers.backend = "podman";

    libvirtd = {
      enable = true;
      allowedBridges = [ "virbr0" ];
      onShutdown = "shutdown";

      qemu = {
        ovmf.enable = true;
        package = pkgs.qemu_kvm;
        swtpm.enable = true;

        # when set to `true`, will let me specify the user and group in `verbatimConfig` (i.e. not override)
        runAsRoot = true;
        verbatimConfig = ''
          #https://github.com/NixOS/nixpkgs/pull/37281#issuecomment-413133203
          namespaces = []
          user = "${nixosSystem.systemUser.username}"
          group = "${nixosSystem.systemUser.username}"

          # Whether libvirt should dynamically change file ownership
          # to match the configured user/group above. Defaults to 1.
          # Set to 0 to disable file ownership changes.
          dynamic_ownership = 1
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
