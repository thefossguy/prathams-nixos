{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.virtualisation.enable {
  # virt-manager gets installed when a GUI session is enabled
  # this exists in case a GUI session is not enabled
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    qemu_kvm
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      allowedBridges = lib.optionals config.customOptions.virtualisation.enableVirtualBridge [ "virbr0" ];
      onShutdown = "shutdown";

      qemu = {
        ovmf.enable = true;
        package = pkgs.qemu_kvm;
        swtpm.enable = true;

        vhostUserPackages = with pkgs; [
          virtiofsd
        ];

        # when set to `true`, will let me specify the user and group in `verbatimConfig` (i.e. not override)
        runAsRoot = true;
        verbatimConfig = ''
          #https://github.com/NixOS/nixpkgs/pull/37281#issuecomment-413133203
          namespaces = []
          user = "${nixosSystemConfig.coreConfig.systemUser.username}"
          group = "${nixosSystemConfig.coreConfig.systemUser.username}"

          # Whether libvirt should dynamically change file ownership
          # to match the configured user/group above. Defaults to 1.
          # Set to 0 to disable file ownership changes.
          dynamic_ownership = 1
        '';
      };
    };
  };
}
