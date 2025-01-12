{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.attrsets.optionalAttrs nixosSystemConfig.coreConfig.isNixOS {
  home.activation = {
    OVMFActivation = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [[ "$(uname -m)" == 'aarch64' ]]; then
          EDKII_CODE_NIX="${pkgs.OVMF.fd}/FV/AAVMF_CODE.fd"
          EDKII_VARS_NIX="${pkgs.OVMF.fd}/FV/AAVMF_VARS.fd"
      elif [[ "$(uname -m)" == 'x86_64' ]]; then
          EDKII_CODE_NIX="${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
          EDKII_VARS_NIX="${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"
      fi

      EDKII_DIR_HOME='/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/share/edk2'
      EDKII_CODE_HOME="''${EDKII_DIR_HOME}/EDKII_CODE"
      EDKII_VARS_HOME="''${EDKII_DIR_HOME}/EDKII_VARS"

      if [ -d "''${EDKII_DIR_HOME}" ]; then
          rm -rf "''${EDKII_DIR_HOME}"
      fi
      mkdir -vp "''${EDKII_DIR_HOME}"

      cp "''${EDKII_CODE_NIX}" "''${EDKII_CODE_HOME}"
      cp "''${EDKII_VARS_NIX}" "''${EDKII_VARS_HOME}"

      chown "''${LOGNAME}":"''${LOGNAME}" "''${EDKII_CODE_HOME}" "''${EDKII_VARS_HOME}"
      chmod 644 "''${EDKII_CODE_HOME}" "''${EDKII_VARS_HOME}"
    '';
  };

  # For `libvirt`, `virt-manager` and `virsh`
  xdg.configFile = {
    # From `libvirt:qemu.conf`
    "libvirt/qemu.conf" = {
      enable = true;
      text = ''
        nvram = [
          "/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/share/edk2/EDKII_CODE:/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/share/edk2/EDKII_VARS",
          "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd",
          "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"
        ]
      '';
    };
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
