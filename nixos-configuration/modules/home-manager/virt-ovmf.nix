{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  userUsername = nixosSystemConfig.coreConfig.systemUser.username;
in
lib.mkIf nixosSystemConfig.coreConfig.isNixOS {
  home.activation = {
    OVMFActivation = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [[ "$(uname -m)" == 'aarch64' ]]; then
          VARS_ARCH='arm'
      elif [[ "$(uname -m)" == 'x86_64' ]]; then
          VARS_ARCH='i386'
      fi
      CODE_ARCH="$(uname -m)"
      EDKII_CODE_NIX="${pkgs.qemu}/share/qemu/edk2-''${CODE_ARCH}-code.fd"
      EDKII_CODE_SEC_NIX="${pkgs.qemu}/share/qemu/edk2-''${CODE_ARCH}-secure-code.fd"
      EDKII_VARS_NIX="${pkgs.qemu}/share/qemu/edk2-''${VARS_ARCH}-vars.fd"

      EDKII_DIR_HOME='${config.home.homeDirectory}/.local/share/edk2'

      if [ -d "''${EDKII_DIR_HOME}" ]; then
          rm -rf "''${EDKII_DIR_HOME}"
      fi
      mkdir -vp "''${EDKII_DIR_HOME}"

      [[ -f "''${EDKII_CODE_NIX}" ]] && cp -v "''${EDKII_CODE_NIX}" "''${EDKII_DIR_HOME}/EDK2_CODE"
      [[ -f "''${EDKII_CODE_SEC_NIX}" ]] && cp -v "''${EDKII_CODE_SEC_NIX}" "''${EDKII_DIR_HOME}/EDK2_CODE_SECURE"
      [[ -f "''${EDKII_VARS_NIX}" ]] && cp -v "''${EDKII_VARS_NIX}" "''${EDKII_DIR_HOME}/EDK2_VARS"

      [[ -f "''${EDKII_CODE_NIX}" ]] && ln -s "''${EDKII_CODE_NIX}" "''${EDKII_DIR_HOME}/edk2_code"
      [[ -f "''${EDKII_CODE_SEC_NIX}" ]] && ln -s "''${EDKII_CODE_SEC_NIX}" "''${EDKII_DIR_HOME}/edk2_code_secure"
      [[ -f "''${EDKII_VARS_NIX}" ]] && ln -s "''${EDKII_VARS_NIX}" "''${EDKII_DIR_HOME}/edk2_vars"

      for zeFile in $(find "''${EDKII_DIR_HOME}/" -type f | tr '\n' ' '); do
          chown ${userUsername}:${userUsername} -v "''${zeFile}"
          chmod 644 -v "''${zeFile}"
      done
    '';
  };

  # For `libvirt`, `virt-manager` and `virsh`
  xdg.configFile = {
    # From `libvirt:qemu.conf`
    "libvirt/qemu.conf" = {
      enable = true;
      text = ''
        nvram = [
          "${config.home.homeDirectory}/.local/share/edk2/EDK2_CODE:${config.home.homeDirectory}/.local/share/edk2/EDK2_VARS",
          "/run/libvirt/nix-ovmf/edk2-aarch64-code.fd:/run/libvirt/nix-ovmf/edk2-arm-vars.fd",
          "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd:/run/libvirt/nix-ovmf/edk2-i386-vars.fd"
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
