{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf nixosSystemConfig.coreConfig.isNixOS {
  home.activation = {
    OVMFActivation = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [[ "$(uname -m)" == 'aarch64' ]]; then
          VARS_ARCH='arm'
      elif [[ "$(uname -m)" == 'x86_64' ]]; then
          VARS_ARCH='i386'
      fi
      CODE_ARCH="$(uname -m)"
      EDKII_CODE_NIX="${pkgs.qemu_full}/share/qemu/edk2-''${CODE_ARCH}-code.fd"
      EDKII_CODE_SEC_NIX="${pkgs.qemu_full}/share/qemu/edk2-''${CODE_ARCH}-secure-code.fd"
      EDKII_VARS_NIX="${pkgs.qemu_full}/share/qemu/edk2-''${VARS_ARCH}-vars.fd"

      EDKII_DIR_HOME='/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/share/edk2'

      if [ -d "''${EDKII_DIR_HOME}" ]; then
          rm -rf "''${EDKII_DIR_HOME}"
      fi
      mkdir -vp "''${EDKII_DIR_HOME}"

      cp -v "''${EDKII_CODE_NIX}" "''${EDKII_DIR_HOME}/EDK2_CODE"
      cp -v "''${EDKII_CODE_SEC_NIX}" "''${EDKII_DIR_HOME}/EDK2_CODE_SECURE"
      cp -v "''${EDKII_VARS_NIX}" "''${EDKII_DIR_HOME}/EDK2_VARS"

      ln -s "''${EDKII_CODE_NIX}" "''${EDKII_DIR_HOME}/edk2_code"
      ln -s "''${EDKII_CODE_SEC_NIX}" "''${EDKII_DIR_HOME}/edk2_code_secure"
      ln -s "''${EDKII_VARS_NIX}" "''${EDKII_DIR_HOME}/edk2_vars"

      chmod 644 -v "''${EDKII_DIR_HOME}/EDK2_"*

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
