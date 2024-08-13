{ config, pkgs, systemUser, ... }:

{
  environment.systemPackages = with pkgs; [
    # should be already included in the base image
    #bzip2
    #curl
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
    #rsync
    #util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    #zstd

    # base system packages + packages what I *need*
    hdparm
    linux-firmware
    parted
    pciutils # provides lspci and setpci
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    smartmontools
    usbutils
    vim # it is a necessity

    # optional, misc packages
    cloud-utils # provides growpart
    dmidecode
    lsof
    minisign
    nvme-cli

    # power management
    acpi
    lm_sensors

    # utilities specific to Nix
    nvd # diff between NixOS generations
  ];

  programs = {
    adb.enable = true;
    bandwhich.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git.enable = true;
    gnupg.agent.enable = true;
    htop.enable = true;
    iotop.enable = true;
    mtr.enable = true;
    skim.fuzzyCompletion = true;
    sniffnet.enable = true;
    tmux.enable = true;
    traceroute.enable = true;
    trippy.enable = true;
    usbtop.enable = true;

    bash = {
      enableCompletion = true;

      # aliases for the root user
      # doesn't affect 'pratham' since there is an `unalias -a` in $HOME/.bashrc
      shellAliases = let
        nixosRebuildCommand = "${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --show-trace --verbose --flake /etc/nixos#${config.networking.hostName}";
        paranoidFlushScript = "/home/${systemUser.username}/.local/scripts/other-common-scripts/paranoid-flush.sh";
      in {
        "e" = "${pkgs.vim}/bin/vim";
        "do-nixos-rebuild" = nixosRebuildCommand;
        "donixos-rebuild" =  nixosRebuildCommand;
        "syncsync" = paranoidFlushScript;
        "sudosync" = paranoidFlushScript;
      };
    };

    nano = {
      enable = true;
      syntaxHighlight = true;
    };
  };
}
