{
  config,
  lib,
  modulesPath,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  sysuser = nixosSystemConfig.coreConfig.systemUser;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../qemu/qemu-guest.nix
  ];

  boot.kernelParams = [
    # Helps on aarch64-linux **and** x86_64-linux
    "console=tty0"
    "console=ttyS0"
  ];
  customOptions.autologinSettings.getty.enableAutologin = true;
  customOptions.autologinSettings.guiSession.enableAutologin = true;
  customOptions.displayServer.guiSession = nixosSystemConfig.extraConfig.guiSession;
  environment.systemPackages = pkgs.callPackage ./packages.nix { inherit pkgs pkgsChannels; };
  system.nixos.tags = [ config.isoImage.edition ];
  # `initialHashedPassword` is used because that is what upstream (nixpkgs) sets and what should be overwritten.
  users.users."${sysuser.username}".initialHashedPassword = lib.mkForce sysuser.hashedPassword;
  # Systems with memory less than 8G get an OOM kill on running `nixos-install`
  # so instead of having one swap device, use two swap devices.
  zramSwap.swapDevices = 2;
  nix.settings.cores = 1;

  # I hate to have home-manager since it is not **necessary** but it is the only
  # way that _I know_ how to create a file in $HOME in NixOS.
  home-manager = {
    useGlobalPkgs = true;
    users."${sysuser.username}" =
      {
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }:
      {
        home.stateVersion = lib.versions.majorMinor lib.version;
        home.file.".profile" = {
          enable = true;
          force = true;
          executable = true;
          text = ''
            set -x

            if ! ${pkgs.iputils}/bin/ping -c 5 'gitlab.com' 1>/dev/null 2>&1; then
                set +x
                echo 'You do not appear to be connected to the internet.'
                echo 'Please clone the following directories manually:'
                echo ' 1. NixOS Configuration: https://gitlab.com/thefossguy/prathams-nixos.git'
                echo ' 2. Dotfiles: https://gitlab.com/thefossguy/dotfiles.git'
                exec bash
            fi

            NIXOS_CONFIG_DIR="$HOME/.prathams-nixos"
            DOTFILES_DIR="$HOME/.dotfiles"

            NIXOS_CONFIG_REPO_URL='https://gitlab.com/thefossguy/prathams-nixos.git'
            DOTFILE_REPO_URL='https://gitlab.com/thefossguy/dotfiles.git'

            git clone "$NIXOS_CONFIG_REPO_URL" "$NIXOS_CONFIG_DIR" || \
                (rm -rf "$NIXOS_CONFIG_DIR" && git clone "$NIXOS_CONFIG_REPO_URL" "$NIXOS_CONFIG_DIR")

            git clone --bare "$DOTFILE_REPO_URL" "$DOTFILES_DIR" || \
                (rm -rf "$DOTFILES_DIR" && git clone --bare "$DOTFILE_REPO_URL" "$DOTFILES_DIR")

            git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout -f
            rm -rf "$HOME/.config/nvim"
            set +x
            exec bash
          '';
        };
      };
  };

  specialisation = {
    longterm.configuration = {
      customOptions.kernelConfiguration.tree = lib.mkForce "longterm";
    };
    mainline.configuration = {
      customOptions.kernelConfiguration.tree = lib.mkForce "mainline";
    };
  };

  isoImage.appendToMenuLabel = " Installer (${config.customOptions.kernelConfiguration.tree})";
  isoImage.edition =
    if (config.customOptions.displayServer.guiSession == "unset") then
      "minimal"
    else
      config.customOptions.displayServer.guiSession;
  image.baseName = lib.mkForce "nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
  image.extension = lib.mkForce "iso";
  isoImage.squashfsCompression = "xz -Xdict-size 100%"; # Highest compression ratio.
  #isoImage.squashfsCompression = "lz4 -b 32768"; # Lowest time to compress.
}
