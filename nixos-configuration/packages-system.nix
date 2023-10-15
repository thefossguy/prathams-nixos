{ pkgs, ... }:

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
    inotify-tools
    iproute
    iputils
    linux-firmware
    lsof
    mlocate
    mtr
    nvme-cli
    openssh
    openssl
    parallel
    pciutils # provides lspci and setpci
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    python3Minimal
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

    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    binutils # provides readelf, objdump, strip, as, objcopy (GNU; not LLVM)
    cargo-audit # audit crates for security vulnerabilities
    #cargo-benchcmp # compare Rust micro-benchmarks # available after 23.05
    cargo-binstall # install Rust binaries instead of building them from src
    cargo-bisect-rustc # find exactly which rustc commit/release-version which prevents your code from building now
    cargo-bloat # find what takes the most space in the executable
    cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
    cargo-chef # for speeding up container builds using layer caching
    cargo-deps # build dependency graph of Rust projects
    cargo-dist # distribute on crates.io
    cargo-flamegraph # flamegraphs without Perl or pipes
    cargo-hack # build project with all the possible variations of options/flags and check which ones fail and/or succeed
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
    gcc
    linux.dev
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # language servers, parsers and other related packages
    clang-tools # provides clangd
    lldb # provides lldb-vscode
    lua-language-server
    nil # language server for Nix
    nodePackages.bash-language-server
    ruff
    shellcheck
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

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    android-tools
    asciinema
    fzf
    picocom
    ubootTools

    ventoy

    # utilities written in Rust
    bandwhich
    bat
    bottom
    broot
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    ripgrep
    sd
    skim
    sniffnet
    tealdeer
    tre-command
    zoxide

    # virtualisation
    #OVMF
    #qemu
    #qemu-utils
    qemu_kvm

    # tools specific to NixOS
    nix-output-monitor
    nvd # diff between NixOS generations
  ];

  programs.gnupg.agent.enable = true;
}
