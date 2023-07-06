{ config, pkgs, ... }:

{
  # packages to be installed _system wide_
  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    coreutils
    dmidecode
    doas
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    git
    gnugrep
    gnupg
    gnused
    hdparm
    iproute
    iputils
    linux-firmware
    lsof
    mlocate
    mtr
    openssh
    openssl
    pciutils # provides lspci and setpci
    pinentry
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    rsync
    shadow
    smartmontools
    tmux
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    wol

    # text editors
    nano
    neovim
    vim

    # shells
    bash
    dash
    zsh

    # download clients
    aria2
    curl
    wget
    yt-dlp

    # compression and decompression
    bzip2
    gnutar
    gzip
    #rar # absent on aarch64, and not really needed
    unzip
    xz
    zip
    zip
    zstd

    # programming
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    cargo-audit # audit crates for security vulnerabilities
    #cargo-benchcmp # compare Rust micro-benchmarks # available after 23.05
    cargo-binstall # install Rust binaries instead of building them from src
    cargo-bloat # find what takes the most space in the executable
    cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
    cargo-chef # for speeding up container builds using layer caching
    cargo-deps # build dependency graph of Rust projects
    cargo-dist # distribute on crates.io
    cargo-flamegraph # flamegraphs without Perl or pipes
    cargo-outdated # show outdated deps
    cargo-profiler # profile Rust binaries
    cargo-public-api # detect breaking API changes and semver violations
    cargo-show-asm # display ASM, LLVM-IR, MIR and WASM for the Rust src
    cargo-sweep # cleanup unused build files
    cargo-udeps # find unused dependencies
    cargo-update # update installed binaries
    cargo-valgrind
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    clang
    gcc
    python311
    ruff
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # language servers and other related packages
    clang-tools # provides clangd
    lldb # provides lldb-vscode
    lua-language-server
    nil # language server for Nix
    nodePackages.bash-language-server
    python311Packages.ruff-lsp
    tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found

    # power management
    acpi
    lm_sensors

    # dealing with other distro's packages
    dpkg
    rpm

    # for media consumption, manipulation and metadata info
    ffmpeg
    imagemagick
    mediainfo

    # system monitoring
    btop
    htop
    htop-vim
    iotop
    iotop-c
    usbtop

    # podman
    aardvark-dns
    #dnsname-cni #idk if this is important or not
    fuse-overlayfs
    iproute
    podman
    podman-compose
    podman-tui
    slirp4netns

    # network monitoring
    bandwhich
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload
    sniffnet

    # other utilities
    android-tools
    fzf
    picocom
    shellcheck

    # utilities written in Rust
    bat
    choose
    dog
    du-dust
    dua
    fd
    hyperfine
    procs
    ripgrep
    skim
    tealdeer
    tre-command

    # virtualisation
    virt-manager

    # zfs
    zfs
    linuxKernel.packages.linux_6_1.zfs

    # window manager
    #bspwm
    #dunst
    #feh
    #i3lock-fancy-rapid
    #jq
    #lxsession
    #picom
    #polybarFull
    #rofi
    #socat
    #sxhkd
    #wmctrl
    #xdg-desktop-portal-kde
  ];

  programs.gnupg.agent.enable = true;
}
