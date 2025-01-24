{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  useMinimalConfig = config.customOptions.useMinimalConfig;
in
{
  imports = [ ./overlays.nix ];
  environment.systemPackages =
    (with pkgs; [
      # should be already included in the base image
      #bzip2
      #curl
      #dash
      file
      #findutils
      #gawk
      #gnugrep
      #gnused
      #gnutar
      #gzip
      #iproute2
      #iputils
      #pinentry # pkg summary: GnuPG’s interface to passphrase input
      #procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
      python3
      ripgrep
      #rsync
      tree
      #util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
      #zstd

      # base system packages + packages what I *need*
      linux-firmware
      pciutils # provides lspci and setpci
      psmisc # provides killall, fuser, pslog, pstree, etc
      vim # it is a necessity

      # utilities specific to Nix
      nix-output-monitor
      nvd # diff between NixOS generations
    ])
    ++ lib.optionals (!useMinimalConfig) (
      with pkgs;
      [
        # optional, misc packages
        cloud-utils # provides growpart
        dmidecode
        hdparm
        lsof
        minisign
        nvme-cli
        parted
        pv
        smartmontools
        usbutils

        # power management
        acpi
        lm_sensors
      ]
    );

  programs = {
    adb.enable = !useMinimalConfig;
    bandwhich.enable = !useMinimalConfig;
    command-not-found.enable = !useMinimalConfig;
    dconf.enable = true;
    git.enable = true; # Always enable git because it's used to manage the NixOS Configuration
    gnupg.agent.enable = !useMinimalConfig;
    htop.enable = true;
    iotop.enable = !useMinimalConfig;
    mtr.enable = !useMinimalConfig;
    skim.fuzzyCompletion = !useMinimalConfig;
    sniffnet.enable = !useMinimalConfig;
    tmux.enable = true;
    traceroute.enable = !useMinimalConfig;
    trippy.enable = !useMinimalConfig;
    usbtop.enable = !useMinimalConfig;

    bash = {
      completion.enable = true;

      # aliases for the root user
      # doesn't affect 'pratham' since there is an `unalias -a` in $HOME/.bashrc
      shellAliases =
        let
          nixosRebuildCommand = "${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --show-trace --verbose --flake /etc/nixos#${config.networking.hostName}";
          paranoidFlushScript = "/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/scripts/other-common-scripts/paranoid-flush.sh";
        in
        {
          "e" = "${pkgs.vim}/bin/vim";
          "donixos-rebuild" = nixosRebuildCommand;
          "sudosync" = paranoidFlushScript;
        };
    };

    nano = {
      enable = true;
      syntaxHighlight = true;
    };
  };
}
